//
//  WeekDay.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import Foundation

enum WeekDay: String {
    case Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday
}

extension WeekDay: CaseIterable, Identifiable, Equatable {
    var id: Self { self }
}

extension WeekDay {
    var shortName: String { Calendar.current.shortWeekdaySymbols[index - 1] }
    
    func fromString(dayString: String) -> WeekDay? {
        WeekDay.allCases.first { $0.rawValue == dayString }
    }
    
    var index: Int { WeekDay.allCases.firstIndex(of: self)! + 1 }
}
