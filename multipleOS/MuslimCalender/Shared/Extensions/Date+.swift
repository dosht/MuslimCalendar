//
//  Date+.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 10.07.2022.
//

import Foundation

extension Date {
    var startOfDay: Date {
        return Calendar(identifier: .gregorian).date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    var endOfDay: Date {
        return Calendar(identifier: .gregorian).date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    var tomorrow: Date {
        return Date(timeInterval: 1, since: endOfDay)
    }
    
    func advancedBy(hour: Int = 0, minute: Int = 0) -> Date {
        advanced(by: Double(hour*60*60 + minute*60))
    }
}
