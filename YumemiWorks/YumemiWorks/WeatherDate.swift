//
//  WeatherDate.swift
//  YumemiWorks
//
//  Created by user on 2023/09/05.
//

import UIKit

class WeatherDate {
    let date: Date
    
    init() {
        self.date = Date()
    }
    
    func dateToString() -> String {
        let formatter = WeatherDateFormatter()
        return formatter.formatToString(date: self.date)
    }

}

class WeatherDateFormatter: DateFormatter {
    private let format: String = "yyyy-MM-ddHH:mm:ssZ"
    private let timeZoneString: Character = "T"
    
    func formatToString(date: Date)  -> String {
        self.calendar = Calendar(identifier: .gregorian)
        self.dateFormat = self.format
        var dateString = self.string(from: date)
        dateString.insert(timeZoneString, at: dateString.index(dateString.startIndex, offsetBy: 10))
        return dateString
    }
    
}
