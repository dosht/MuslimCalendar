//
//  Date+.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import Foundation

extension Date {
    init(timeString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = .gmt
        let date = dateFormatter.date(from: timeString)!
        self.init(timeInterval: 0, since: date)
    }
    
    //TODO: Use Calendar.current.startOfDay(for: self)
    var startOfDay: Date {
        return Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    var endOfDay: Date {
        return Calendar(identifier: .gregorian).date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    var tomorrow: Date {
        return Date(timeInterval: 1, since: endOfDay)
    }
}
