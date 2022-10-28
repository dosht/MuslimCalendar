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
        (startRelativeTo < endRelativeTo) ? .full : (end - start > 0) ? .beginning : .end
    }
}

extension ScheduleItem {
    func syncWrappedObject(_ context: NSManagedObjectContext) {
        let obj = wrappedObject ?? RelativeEvent.init(context: context)
        obj.title = title
        obj.startRelativeTo = Int32(startRelativeTo)
        obj.endRelativeTo = Int32(endRelativeTo)
        obj.start = start
        obj.end = end
        try! context.save()
    }
}
