//
//  WeatherListViewController.swift
//  YumemiWorks
//
//  Created by user on 2023/09/06.
//

import UIKit

class WeatherListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var weatherTableView: UITableView!
    
    var weatherList:[WeatherCondition] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
        
        // pullToRefresh実装
        weatherTableView.refreshControl = UIRefreshControl()
        weatherTableView.refreshControl?.addTarget(self, action: #selector(onRefresh(_:)), for: .valueChanged)
        
        // 表示時にリスト取得
        self.getWeatherListData()
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func onRefresh(_ sender: AnyObject) {
        Task {
            self.getWeatherListData()
        }
    }
    
    func getWeatherListData() {
        let fetchWeatherListApi = FetchWeatherListAPI()
        Task {
            do {
                let weatherList = try await fetchWeatherListApi.fetchWeatherList()
                self.weatherList = weatherList
                self.refreshTableView()
            }
            catch {
                // エラーメッセージだす。
                print("Failed")
                self.showWeatherDataFetchAlert(message: error.localizedDescription)
            }
            self.weatherTableView.refreshControl?.endRefreshing()
        }
    }

    @objc func refreshTableView() {
        weatherTableView.refreshControl?.endRefreshing()
        weatherTableView.reloadData()
    }
    
    // 失敗時のエラーを出す
    func showWeatherDataFetchAlert(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "天候情報の取得でエラーが発生しました。\n再取得するにはPullToRefreshを行ってください", message: message, preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: "OK", style: .destructive)
            alertController.addAction(actionCancel)
            self.present(alertController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = weatherTableView.dequeueReusableCell(withIdentifier: "weatherViewCell", for: indexPath) as? WeatherListViewCell else {
            // 例外:とりあえず空で返す
            let cell = UITableViewCell()
            return cell
        }

        // Configure the cell...
        if self.weatherList.count != 0 {
            cell.areaName.text = weatherList[indexPath.row].areaName
            cell.maxTemp.text = weatherList[indexPath.row].maxTemperature.getDisplayTemperature()
            cell.minTemp.text = weatherList[indexPath.row].minTemperature.getDisplayTemperature()
            cell.weatherImage.image = UIImage(named: weatherList[indexPath.row].condition.rawValue)
            cell.weatherImage.tintColor = UIColor(named: weatherList[indexPath.row].condition.rawValue)
        }
        
        return cell
    }
    
    // Cell が選択された場合に解除しないとRejectされるらしいので追加
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /// セグエで情報を受け渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWeatherView" {
            if let indexPath = weatherTableView.indexPathForSelectedRow {
                guard let weatherViewController = segue.destination as? WeatherViewController else {
                    fatalError("Failed to prepare DetailViewController.")
                }
                let tappedWeather = self.weatherList[indexPath.row]
                weatherViewController.weatherCondition = tappedWeather
            }
        }
    }
    
}
