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
        let date = dateFormatter.date(from: timeString)!
        self.init(timeInterval: 0, since: date)
    }
}
