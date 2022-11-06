//
//  CoreDate+ScheduledItem.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 27.10.2022.
//

import Foundation
import CoreData

extension RelativeEvent {
    var scheuledItem: ScheduleItem {
        ScheduleItem(
            title: title ?? "",
            startTime: Date(),
            duration: 0,
            type: .event,
            scheduleRule: scheduleRule,
            startRelativeTo: Int(startRelativeTo),
            endRelativeTo: Int(endRelativeTo),
            start: start,
            end: end,
            wrappedObject: self
        )
    }
}

extension RelativeEvent {
    var scheduleRule: ScheduleItem.ScheduleRule {
        (startRelativeTo < endRelativeTo) ? .full : start > 0 ? .beginning : .end
    }
}

extension ScheduleItem {
    func syncWrappedObject(_ context: NSManagedObjectContext) {
        let wrappedObject = wrappedObject ?? RelativeEvent.init(context: context)
        wrappedObject.title = title
        wrappedObject.startRelativeTo = Int32(startRelativeTo)
        wrappedObject.endRelativeTo = Int32(endRelativeTo)
        wrappedObject.start = start
        wrappedObject.end = end
        if let eventIdentifier = wrappedEkEvent?.eventIdentifier {
            wrappedObject.ekEventIdentifier = eventIdentifier
        }
        try! context.save()
    }
}
