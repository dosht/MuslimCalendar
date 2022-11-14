//
//  ScheduleTiem.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import Foundation
import EventKit

struct ScheduleItem {
    var id: String = UUID().uuidString
    var title: String
    var startTime: Date
    var duration: TimeInterval
    var type: ScheduleItemType
    var scheduleRule: ScheduleRule = .beginning
    var startRelativeTo: Int = 0
    var endRelativeTo: Int = 0
    var start: TimeInterval = 0
    var end: TimeInterval = 0
    var wrappedObject: RelativeEvent?
    var wrappedEkEvent: EKEvent?
    var alertOffset: TimeInterval?
    
    enum ScheduleRule: Equatable, Hashable {
        case beginning, end, full
    }
}

extension ScheduleItem {
    var endTime: Date {
        startTime.addingTimeInterval(duration)
    }
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
            ScheduleItem(title: "\(dayString)event 1", startTime: Date(timeString: "04:00"), duration: 60*15, type: .event),
            ScheduleItem(title: "fajr",  startTime: Date(timeString: "04:30"), duration: 0, type: .prayer),
            ScheduleItem(title: "\(dayString)event 2", startTime: Date(timeString: "04:30"), duration: 60*30, type: .event),
            ScheduleItem(title: "", startTime: Date(timeString: "05:00"), duration: 7*60*60, type: .availableTime),
            ScheduleItem(title: "duhr", startTime: Date(timeString: "12:00"), duration: 0, type: .prayer),
            ScheduleItem(title: "\(dayString)event 3", startTime: Date(timeString: "12:00"), duration: 60*80, type: .event),
        ]
    }
    
    static var sample: [ScheduleItem] { createSample() }
    static var prayerSample: [ScheduleItem] { sample.filter { $0.type == .prayer } }
    static var eventSample: [ScheduleItem] { sample.filter { $0.type == .event } }
    static var availableTimeSample: [ScheduleItem] { sample.filter { $0.type == .availableTime } }
}

extension ScheduleItem: Comparable {
    static func < (lhs: ScheduleItem, rhs: ScheduleItem) -> Bool {
        (lhs.startTime, lhs.duration) < (rhs.startTime, rhs.duration)
    }
}

struct Allocation {
    var startTime: Date
    var endTime: Date
    var startRelativeTo: Int
    var start: TimeInterval
    var endRelativeTo: Int
    var end: TimeInterval
    
    var duration: TimeInterval { endTime.timeIntervalSince(startTime) }
}

//MARK: - DO NOT TOUCH
extension ScheduleItem {
    mutating func reschedule(allocation: Allocation) {
        switch scheduleRule {
        case .beginning: startTime = allocation.startTime;                              startRelativeTo = allocation.startRelativeTo; start = allocation.start;               endRelativeTo = allocation.startRelativeTo; end = allocation.start + duration
        case .end:       startTime = allocation.endTime.addingTimeInterval(-duration);  startRelativeTo = allocation.endRelativeTo;   start = allocation.end - duration; endRelativeTo = allocation.endRelativeTo;   end = allocation.end
        case .full:      startTime = allocation.startTime;                              startRelativeTo = allocation.startRelativeTo; start = allocation.start;               endRelativeTo = allocation.endRelativeTo;   end = allocation.end
            duration = allocation.duration
        }
    }
}

extension Array<ScheduleItem> {
    func allocation(of item: ScheduleItem) -> Allocation? {
        guard let itemIndex = firstIndex(where: { $0.id == item.id }) else { return nil }
        let itemAfter = self[index(after: itemIndex)]
        let itemBefore = self[index(before: itemIndex)]
        return Allocation(
            startTime: (itemBefore.type == .availableTime) ? itemBefore.startTime : itemBefore.endTime,
            endTime: (itemAfter.type == .availableTime) ? itemAfter.endTime : itemAfter.startTime,
            startRelativeTo: (itemBefore.type == .availableTime) ? itemBefore.startRelativeTo : itemBefore.endRelativeTo,
            start: (itemAfter.type == .availableTime) ? itemBefore.end : itemBefore.start,
            endRelativeTo: (itemAfter.type == .availableTime) ? itemAfter.endRelativeTo : itemAfter.startRelativeTo,
            end: (itemAfter.type == .availableTime) ? itemAfter.end : itemAfter.start
        )
    }
}
//MARK: - END DON'T TOUCH

extension ScheduleItem {
    static let DefaultDuration: TimeInterval = 30*60
    func createNewEvent() -> ScheduleItem {
        var newItem = ScheduleItem(
            title: "",
            startTime: startTime,
            duration: ScheduleItem.DefaultDuration,
            type: .event,
            startRelativeTo: startRelativeTo,
            endRelativeTo: startRelativeTo,
            start: start,
            end: ScheduleItem.DefaultDuration + start
        )

        if duration <= ScheduleItem.DefaultDuration {
            newItem.scheduleRule = .full
            newItem.duration = duration
            newItem.end = newItem.duration + start
        }
        return newItem
    }
}
