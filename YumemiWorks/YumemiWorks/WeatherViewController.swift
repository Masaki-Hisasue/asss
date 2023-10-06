//
//  ViewController.swift
//  YumemiWorks
//
//  Created by user on 2023/09/04.
//

import UIKit

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherImageView: UIImageView!

    @IBOutlet weak var minTemperature: UILabel!
    @IBOutlet weak var maxTemperature: UILabel!
    
    @IBOutlet weak var listViewIndicator: UIActivityIndicatorView!
    
    var weatherCondition: WeatherCondition?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // BG→FG復帰時の監視用Observer設定
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil
        )
        // コメントアウトを外せばLargeTitleになる
        //        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // 初回表示時の画面更新
        if let condition = self.weatherCondition {
            self.refreshWeatherCondition(weatherCondition: condition)
        }
    }
    
    @objc func enterForeground(notification: Notification) {
        self.reloadWeatherInformation()
    }
    
    deinit {
        print("Closed Viewcontroller.")
    }

    
    @IBAction func pushReloadButton(_ sender: Any) {
        self.reloadWeatherInformation()
    }

    @IBAction func close(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func reloadWeatherInformation() {
        let weatherReload = CityWeatherReload()
        weatherReload.reload(viewController: self)
        self.startIndicator()
    }
    
    private func startIndicator() {
        // 画面更新処理なのでmainスレッドで実施
        DispatchQueue.main.async {
            self.listViewIndicator.startAnimating()
        }
    }
    
    private func stopIndicator() {
        // 画面更新処理なのでmainスレッドで実施
        DispatchQueue.main.async {
            self.listViewIndicator.stopAnimating()
        }
    }
    
    func refreshWeatherCondition(weatherCondition: WeatherCondition) {
        self.weatherCondition = weatherCondition
        self.stopIndicator()
        self.changeWeatherImage()
        self.changeMinTemperature()
        self.changeMaxTemperature()
        self.changeNavigationBarTitle()
    }
    
    private func changeWeatherImage() {
        guard let weatherCondition = self.weatherCondition else {
            return
        }
        // 画面更新処理なのでmainスレッドで実施
        DispatchQueue.main.async {
            switch weatherCondition.condition {
            case .sunny, .cloudy, .rainy:
                self.weatherImageView.isHidden = false
                self.weatherImageView.image = UIImage(named: weatherCondition.condition.rawValue)
                self.weatherImageView.tintColor = UIColor(named: weatherCondition.condition.rawValue)
            case .other:
                // 上記以外は変更の必要なし（現状エラーのみ）
                break
            }
        }
    }
    
    private func changeMaxTemperature() {
        guard let weatherCondition = self.weatherCondition else {
            return
        }
        // 画面更新処理なのでmainスレッドで実施
        DispatchQueue.main.async {
            let temparature = weatherCondition.maxTemperature
            self.maxTemperature.text = temparature.getDisplayTemperature()
        }
    }
    
    private func changeMinTemperature() {
        guard let weatherCondition = self.weatherCondition else {
            return
        }
        // 画面更新処理なのでmainスレッドで実施
        DispatchQueue.main.async {
            let temparature = weatherCondition.minTemperature
            self.minTemperature.text = temparature.getDisplayTemperature()
        }
    }
    
    private func changeNavigationBarTitle() {
        guard let weatherCondition = self.weatherCondition else {
            return
        }
        // 画面更新処理なのでmainスレッドで実施
        DispatchQueue.main.async {
            self.navigationItem.title = weatherCondition.areaName
        }
    }
    
    func showWeatherDataFetchAlert(message: String) {
        self.stopIndicator()
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "天候情報の取得でエラーが発生しました", message: message, preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "OK", style: .destructive)
            alertController.addAction(actionCancel)
            self.present(alertController, animated: true)
        }
    }

}

