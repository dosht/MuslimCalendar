//
//  File.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 3.11.2022.
//

import Foundation

extension Date {
    var weekDayLocalised: String {
        let index = Calendar.current.component(.weekday, from: self)
        return Calendar.current.weekdaySymbols[index - 1]
    }
    
    func this(_ day: WeekDay) -> Date {
        Calendar.current.date(byAdding: .day, value: day.index - weekDay.index, to: self)!
    }

    var weekDay: WeekDay {
        let index = Calendar.current.component(.weekday, from: self)
        return WeekDay.allCases[index - 1]
    }
}

