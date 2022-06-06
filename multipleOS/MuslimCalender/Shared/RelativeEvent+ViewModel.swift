//
//  RelativeEvent+ViewModel.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 3.06.2022.
//

import Foundation
import SwiftUI
import CoreData
import CoreLocation

class RelativeEventsViewModel: ObservableObject {
    private let context: NSManagedObjectContext
    
    @Published
    var relativeEvents: [RelativeEvent] = []
    
    @Published
    var chosenAllocatableSlot: RelativeEvent? = nil
    
    @Published
    var editedEvent: RelativeEvent? = nil
    
    var location: CLLocationCoordinate2D
    
    init (context: NSManagedObjectContext, location: CLLocationCoordinate2D) {
        self.context = context
        self.location = location
    }
    
    func duration(event: RelativeEvent) -> Double {
        let prayerCalculator: PrayerCalculator? = PrayerCalculator(location: location, date: Date())
        return event.duration(time: prayerCalculator!.time)
    }
    
    var isNew: Bool {
        if let editedEvent = editedEvent {
            return editedEvent.isInserted
        }
        return false
    }
    
    
    // MARK: Intent(s)
    
    var addingNewEvent: Bool {
        get { (chosenAllocatableSlot != nil)  && (editedEvent != nil) }
        set {
            if newValue == false {
                chosenAllocatableSlot = nil
                editedEvent = nil
                context.rollback()
            }
        }
    }
    
    var editingEvent: Bool {
        get { editedEvent != nil }
        set {
            if newValue == false {
                editedEvent = nil
                context.rollback()
            }
        }
    }

    @discardableResult
    func fetch() -> [RelativeEvent] {
        let request = NSFetchRequest<RelativeEvent>(entityName: "RelativeEvent")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \RelativeEvent.startRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.start, ascending: true)
        ]
        do {
            relativeEvents = try context.fetch(request)
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
        return relativeEvents
    }
    
    func chooseAllocatableSlot(allcatableSlot: RelativeEvent) {
        chosenAllocatableSlot = allcatableSlot
        editedEvent = RelativeEvent.create(context, "")
        // Connect the event to start prayer time only fo now
        editedEvent?.startRelativeTo = allcatableSlot.startRelativeTo
        editedEvent?.endRelativeTo = allcatableSlot.startRelativeTo
    }
    
    func edit(event: RelativeEvent) {
        editedEvent = event
    }
    
    func save() {
        chosenAllocatableSlot?.start += duration(event: editedEvent!)
        try? context.save()
        editedEvent = nil
        chosenAllocatableSlot = nil
        fetch()
    }
    
    func delete() {
        context.delete(editedEvent!)
        try? context.save()
        fetch()
        editedEvent = nil
    }
    
    func deleteEvent(indexSet: IndexSet) {
        
    }
    
    func deleteAll() {
        fetch().forEach(context.delete)
        do {
            try context.save()
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
        fetch()
    }
}

extension TimeInterval {
    var hour: Int? {
        toOptional(Int(self / 60 / 60))
    }
    
    var minute: Int? {
        toOptional(Int(self / 60) - (hour ?? 0) * 60)
    }
    
    private func toOptional(_ value: Int) -> Int? {
        if value == 0 {
            return nil
        }
        return value
    }
    
    var timeIntervalText: String {
        var result = ""
        if let hour = hour, let minute = minute {
            result = "\(abs(hour)) hour, \(abs(minute)) minute"
        }
        else if let hour = hour {
            result = "\(abs(hour)) hour"
        }
        else if let minute = minute {
            result = "\(abs(minute)) minute"
        }
        return result
    }
    
    var timeIntervalShortText: String {
        var result = ""
        if let hour = hour, let minute = minute {
            result = "\(abs(hour))h, \(abs(minute))m"
        }
        else if let hour = hour {
            result = "\(abs(hour))h"
        }
        else if let minute = minute {
            result = "\(abs(minute))m"
        }
        return result
    }
    
}

extension RelativeEvent {
    var isAfter: Bool {
        get { start >= 0 }
        set { start = (newValue ? abs(start) : -abs(start)) }
    }
    
    var startText: String {
        var result = start.timeIntervalText
        if result.isEmpty {
            result = "on time of"
        } else {
            result += isAfter ? " after" : " before"
        }
        return result
    }
}
