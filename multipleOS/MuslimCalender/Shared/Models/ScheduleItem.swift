//
//  ScheduleItem.swift
//  MuslimCalender (iOS)
//
//  Created by Mustafa Abdelhamıd on 3.10.2022.
//

import Foundation

struct ScheduleItem {
    var title: String
    var end: Double
    var start: Double
    var endRelativeTo: Int16
    var startRelativeTo: Int16
    var startDate: Date
    var duration: TimeInterval
    var type: ScheduleItemType
    var relativeEvent: RelativeEvent?
    var ekEventIdentifier: String? {
        get { relativeEvent?.ekEventIdentifier }
        set { relativeEvent?.ekEventIdentifier = newValue }
    }
}

extension ScheduleItem: Hashable, Identifiable {
    var id: Self { self }
}

extension ScheduleItem: Comparable {
    static func < (lhs: ScheduleItem, rhs: ScheduleItem) -> Bool {
        (lhs.startRelativeTo, lhs.endRelativeTo, lhs.start, lhs.end) <
            (rhs.startRelativeTo, rhs.endRelativeTo, rhs.start, rhs.end)
    }
}

enum ScheduleItemType {
    case prayer, event, availableTime
}
