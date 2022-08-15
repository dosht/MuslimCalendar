//
//  RelativeEvent+Model.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 3.06.2022.
//

import Foundation
import CoreData

extension RelativeEvent {
    static func create(_ context: NSManagedObjectContext, _ title: String? = nil) -> RelativeEvent {
        let result = RelativeEvent(context: context)
        result.title = title
        result.isAllocatable = false
        return result
    }
    
    @discardableResult
    func startAt(_ start: Double, relativeTo startRelativeTo: TimeName) -> RelativeEvent {
        self.start = start
        self.startRelativeTo = startRelativeTo.intValue
        return self
    }
    
    @discardableResult
    func endAt(_ end: Double, relativeTo endRelativeTo: TimeName) -> RelativeEvent {
        self.end = end
        self.endRelativeTo = endRelativeTo.intValue
        return self
    }
    
    @discardableResult
    func isAllocatable(_ isAllocatable: Bool) -> RelativeEvent {
        self.isAllocatable = isAllocatable
        return self
    }
    
    var isAdhan: Bool {
        TimeName.allCases.map({ $0.rawValue }).contains(title)
    }
    
    var startTimeName: TimeName {
        get { TimeName.allCases[Int(self.startRelativeTo)] }
        set { self.startRelativeTo = newValue.intValue }
    }
    
    var endTimeName: TimeName {
        get { TimeName.allCases[Int(self.endRelativeTo)] }
        set { self.endRelativeTo = newValue.intValue }
    }
    
    func duration(time: (TimeName) -> Date) -> TimeInterval {
        return round(
            end - start + time(endTimeName).timeIntervalSince(time(startTimeName))
        )
    }
    
    func allocate(newEvent: RelativeEvent) {
        if newEvent.startTimeName == startTimeName && newEvent.endTimeName == endTimeName {
            start = 0
            end = 0
            endTimeName = startTimeName
            return
        }
        if newEvent.startTimeName == startTimeName {
            start = newEvent.end
        }
        if newEvent.endTimeName == endTimeName {
            end = newEvent.start
        }
    }
    
    func expandAllocatableSlot(context: NSManagedObjectContext) -> RelativeEvent {
        let request = NSFetchRequest<RelativeEvent>(entityName: "RelativeEvent")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \RelativeEvent.startRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.endRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.start, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.end, ascending: true),
        ]
        let events: [RelativeEvent] = (try? context.fetch(request)) ?? []
        let thisIndex = events.firstIndex(where: { e in e.id == self.id })
        var allocAfter: Optional<RelativeEvent> = nil
        if let thisIndex = thisIndex {
            if thisIndex < events.count - 1 && events[thisIndex+1].isAllocatable {
                allocAfter = events[thisIndex+1].startAt(self.start, relativeTo: self.startTimeName)
            }
        }
        var allocBefore: RelativeEvent? = nil
        if let thisIndex = thisIndex {
            if thisIndex > 0 && events[thisIndex-1].isAllocatable {
                allocBefore = events[thisIndex-1].endAt(self.end, relativeTo: self.endTimeName)
            }
        }
        return allocAfter ?? allocBefore ?? RelativeEvent.create(context)
            .isAllocatable(true)
            .startAt(self.start, relativeTo: self.startTimeName)
            .endAt(self.end, relativeTo: self.endTimeName)
    }
}
