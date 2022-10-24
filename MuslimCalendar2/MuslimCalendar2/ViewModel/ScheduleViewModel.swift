//
//  ScheduleViewModel.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

class ScheduleViewModel: ObservableObject {
    // MARK: - Publisher(s)
    @Published
    var items: [ScheduleItem] = ScheduleItem.eventSample
    
    @Published
    var day: WeekDay = .Monday

    // MARK: - Intent(s)
    func selectDay(day: WeekDay) {
        self.day = day
    }
    
    func loadItems() {
        self.items = ScheduleItem.createSample(day: day)
    }
}
