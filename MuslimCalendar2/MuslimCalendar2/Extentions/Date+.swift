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
        dateFormatter.timeZone = .init(secondsFromGMT: 0)
        let date = dateFormatter.date(from: timeString)!
        self.init(timeInterval: 0, since: date)
    }
    
    //TODO: Use Calendar.current.startOfDay(for: self)
    var startOfDay: Date {
        Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    var endOfDay: Date {
        Calendar(identifier: .gregorian).date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    var tomorrow: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    var endOfWeek: Date {
        this(.Saturday)
    }
    
    var nextWeek: Date {
        Calendar.current.date(byAdding: .day, value: 7, to: self)!
    }
}
