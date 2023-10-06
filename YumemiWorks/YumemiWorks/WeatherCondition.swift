//
//  WeatherCondition.swift
//  YumemiWorks
//
//  Created by user on 2023/09/05.
//

import UIKit

class WeatherCondition {
    
    enum ConditionType: String {
        case sunny = "sunny"
        case cloudy = "cloudy"
        case rainy = "rainy"
        case other = "other"
    }
    
    let areaName: String
    let condition: ConditionType
    let maxTemperature: Temperature
    let minTemperature: Temperature
    
    init(cityName: String, weatherString: String, max: Int, min: Int) {
        self.areaName = cityName
        // どの天気であるか
        if weatherString == ConditionType.sunny.rawValue {
            self.condition = .sunny
        } else if weatherString == ConditionType.cloudy.rawValue {
            self.condition = .cloudy
        } else if weatherString == ConditionType.rainy.rawValue {
            self.condition = .rainy
        } else {
            // 何も該当しなかった場合は未分類（エラー）
            self.condition = .other
        }
        
        // 最低気温と最高気温の設定
        self.maxTemperature = Temperature(temperature: max)
        self.minTemperature = Temperature(temperature: min)
    }
    
}

// 気温クラス
class Temperature {
    private let temperature: Int
    
    init(temperature: Int) {
        self.temperature = temperature
    }
    
    func getDisplayTemperature() -> String {
        return self.temperature.description
    }
    
}
