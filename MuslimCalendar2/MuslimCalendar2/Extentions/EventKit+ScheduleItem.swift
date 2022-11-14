//
//  EventKit+ScheduleItem.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 14.11.2022.
//

import Foundation
import EventKit

extension ScheduleItem {
    mutating func loadEkEvent(ekEvent: EKEvent) {
        self.alertOffset = ekEvent.alarms?.first?.relativeOffset
        self.wrappedEkEvent = ekEvent
    }
}
