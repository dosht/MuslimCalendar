//
//  WeekDay.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import Foundation

enum WeekDay: String {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}

extension WeekDay: CaseIterable, Identifiable, Equatable {
    var id: Self { self }
}
