//
//  FetchWeatherAPI.swift
//  YumemiWorks
//
//  Created by user on 2023/09/05.
//

import UIKit
import YumemiWeather

class FetchWeatherAPI {
    
    // ここに都市名の変数追加。initの時にもらうようにする。
    private let cityName: String
    
    init (cityName: String) {
        self.cityName = cityName
    }
    
    func fetchWeather() async throws -> WeatherCondition {
        let area = "tokyo" // 現状では固定値で仮入れ
        let date = WeatherDate() // 現状では現在時刻とする
        let dateString = date.dateToString()
        guard let requestJsonStirng = self.makeRequestJson(area: area, date: dateString) else {
            let errorMessage = "内部処理でJsonへの変換に失敗しました"
            print(errorMessage)
            throw NSError(domain: errorMessage, code: 0)
        }
        do {
            let condition = try await self.syncFetchWeather(requestJsonStirng: requestJsonStirng)
            return condition
        } catch {
            throw error
        }
    }
    
    // awaitが入るので別スレッドで実施
    private func syncFetchWeather(requestJsonStirng: String) async throws -> WeatherCondition {
        do {
            let response = try YumemiWeather.syncFetchWeather(requestJsonStirng)
            guard let weatherData = self.makeResponseData(responseJsonString: response) else {
                let errorMessage = "受領データのデコードに失敗しました"
                print(errorMessage)
                throw NSError(domain: errorMessage, code: 1)
            }
            let weather = weatherData.weather_condition
            let max = weatherData.max_temperature
            let min = weatherData.min_temperature
            let condition = WeatherCondition(cityName: self.cityName, weatherString: weather, max: max, min: min)
            return condition
        } catch {
            print("Exception Occured. error = \(error)")
            throw error
        }
    }
    
    private func makeRequestJson(area: String, date: String) -> String? {
        let codableData = RequestWeatherData(area: area, date: date)
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codableData) else {
            print("Failed to encode to JSON.")
            return nil
        }
        // Stringで要求するので変換
        let jsonString = String(decoding: jsonValue, as: UTF8.self)
        return jsonString
    }
    
    private func makeResponseData(responseJsonString: String) -> ResponseWeatherData?{
        // StringをDataにする
        let jsonData = Data(responseJsonString.utf8)
        // Dataに整えたものをCodableにデコードする
        let decoder = JSONDecoder()
        guard let weatherData = try? decoder.decode(ResponseWeatherData.self, from: jsonData) else {
            print("Failed to decode to JSON.")
            return nil
        }
        return weatherData
    }

}

struct RequestWeatherData: Codable {
    var area: String
    var date: String
}

struct ResponseWeatherData: Codable {
    var max_temperature: Int
    var date: String
    var min_temperature: Int
    var weather_condition: String
}
