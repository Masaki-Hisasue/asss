//
//  WeatherReload.swift
//  YumemiWorks
//
//  Created by user on 2023/09/05.
//

import Foundation
import YumemiWeather

class CityWeatherReload {
    
    private let cityName: String = "tokyo" //仮実装で固定
        
    private weak var viewController: WeatherViewController?
    
    func reload(viewController: WeatherViewController) {
        // 取得後の呼び元を保持
        self.viewController = viewController
        // 情報取得依頼（非同期）
        let fetchApi = FetchWeatherAPI(cityName: self.cityName)
        Task {
            do {
                let condition = try await fetchApi.fetchWeather()
                self.didChangedWeather(weatherCondition: condition)
            } catch {
                self.failedToFetchWeather(error: error)
            }
        }
    }

    /// protocol method
    func didChangedWeather(weatherCondition: WeatherCondition) {
        // 天候情報の更新依頼
        viewController?.refreshWeatherCondition(weatherCondition: weatherCondition)
    }
    
    func failedToFetchWeather(error: Any) {
        // 取得失敗エラー表示依頼
        var errorMessage = ""
        
        if let yumemiError = error as? YumemiWeatherError {
            errorMessage = yumemiError.localizedDescription
        } else {
            errorMessage = "予期せぬエラーです"
        }
        self.viewController?.showWeatherDataFetchAlert(message: errorMessage)
    }
}
