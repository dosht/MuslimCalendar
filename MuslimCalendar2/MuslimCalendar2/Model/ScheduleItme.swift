//
//  ScheduleTiem.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import Foundation

struct ScheduleItem {
    var id: String = UUID().uuidString
    var title: String
    var startTime: Date
    var duration: TimeInterval
    var type: ScheduleItemType
}

extension ScheduleItem: Identifiable, Equatable, Hashable {
    
}

enum ScheduleItemType {
    case prayer, event, availableTime
}

extension ScheduleItem {
    static func createSample(day: WeekDay? = nil) -> [ScheduleItem] {
        let dayString = day?.rawValue.appending(" ") ?? ""
        return [
            ScheduleItem(title: "\(dayString)event 1", startTime: Date(timeString: "04:00"), duration: 60*30, type: .event),
            ScheduleItem(title: "fajr",  startTime: Date(timeString: "04:30"), duration: 0, type: .prayer),
            ScheduleItem(title: "\(dayString)event 2", startTime: Date(timeString: "04:30"), duration: 60*30, type: .event),
            ScheduleItem(title: "", startTime: Date(timeString: "05:00"), duration: 7*60*60, type: .availableTime),
            ScheduleItem(title: "duhr", startTime: Date(timeString: "12:00"), duration: 0, type: .prayer)
        ]
    }
    
    static var sample: [ScheduleItem] { createSample() }
    static var prayerSample: [ScheduleItem] { sample.filter { $0.type == .prayer } }
    static var eventSample: [ScheduleItem] { sample.filter { $0.type == .event } }
    static var availableTimeSample: [ScheduleItem] { sample.filter { $0.type == .availableTime } }
}
