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
    
    var startTimeName: TimeName {
        get { TimeName.allCases[Int(self.startRelativeTo)] }
        set { self.startRelativeTo = newValue.intValue }
    }
    
    var endTimeName: TimeName {
        get { TimeName.allCases[Int(self.endRelativeTo)] }
        set { self.endRelativeTo = newValue.intValue }
    }
    
    func duration(time: (TimeName) -> Date) -> TimeInterval {
        print("time name: \(startTimeName), start: \(start), end: \(end), diff: \(time(endTimeName).timeIntervalSince(time(startTimeName)))")
        return round(
            end - start + time(endTimeName).timeIntervalSince(time(startTimeName))
        )
    }
    
}
