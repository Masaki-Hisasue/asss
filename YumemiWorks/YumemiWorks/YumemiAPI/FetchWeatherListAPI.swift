//
//  FetchWeatherListAPI.swift
//  YumemiWorks
//
//  Created by user on 2023/09/06.
//

import UIKit
import YumemiWeather

class FetchWeatherListAPI {
    
    func fetchWeatherList() async throws -> [WeatherCondition] {
        let areas = Area.allCases
        let date = WeatherDate() // 現状では現在時刻とする
        let dateString = date.dateToString()
        guard let requestJsonStirng = self.makeRequestJson(areas: areas, date: dateString) else {
            let errorMessage = "内部処理でJsonへの変換に失敗しました"
            print(errorMessage)
            throw NSError(domain: errorMessage, code: 0)
        }
        do {
            let condition = try await self.syncFetchWeatherList(requestJsonStirng: requestJsonStirng)
            return condition
        } catch {
            throw error
        }
    }
    
    // awaitが入るので別スレッドで実施
    private func syncFetchWeatherList(requestJsonStirng: String) async throws -> [WeatherCondition] {
        do {
            let response = try await YumemiWeather.asyncFetchWeatherList(requestJsonStirng)
            guard let weatherDataList = self.makeResponseData(responseJsonString: response) else {
                let errorMessage = "受領データのデコードに失敗しました"
                print(errorMessage)
                throw NSError(domain: errorMessage, code: 1)
            }
            // for 文章まわしてWeatherConditionのリストをつくる。
            var weatherConditions: [WeatherCondition] = []
            for response in weatherDataList {
                let area = response.area
                let weather = response.info.weather_condition
                let max = response.info.max_temperature
                let min = response.info.min_temperature
                let condition = WeatherCondition(cityName: area, weatherString: weather, max: max, min: min)
                weatherConditions.append(condition)
            }
            return weatherConditions
        } catch {
            print("Exception Occured. error = \(error)")
            throw error
        }
    }
    
    private func makeRequestJson(areas: [Area], date: String) -> String? {
        let codableData = RequestWeatherList(areas: areas, date: date)
        let encoder = JSONEncoder()
        guard let jsonValue = try? encoder.encode(codableData) else {
            print("Failed to encode to JSON.")
            return nil
        }
        // Stringで要求するので変換
        let jsonString = String(decoding: jsonValue, as: UTF8.self)
        return jsonString
    }
    
    private func makeResponseData(responseJsonString: String) -> [ResponseWeatherDataWithArea]?{
        // StringをDataにする
        let jsonData = Data(responseJsonString.utf8)
        // Dataに整えたものをCodableにデコードする
        let decoder = JSONDecoder()
        guard let weatherData = try? decoder.decode([ResponseWeatherDataWithArea].self, from: jsonData) else {
            print("Failed to decode to JSON.")
            return nil
        }
        return weatherData
    }

}

struct RequestWeatherList: Codable {
    var areas: [Area]
    var date: String
}


struct ResponseWeatherDataWithArea: Codable {
    var area: String
    var info: ResponseWeatherData
}
