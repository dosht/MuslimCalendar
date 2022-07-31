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
    private let eventStore: EventStore
    
    @Published
    var relativeEvents: [RelativeEvent] = []
    
    @Published
    var addingNewEvent: Bool = false
    
    @Published
    var editingEvent: Bool = false
    
    @Published
    var editEventViewModel: EditEventViewModel? = nil
//
//    @Published
    var chosenAllocatableSlot: RelativeEvent? = nil
//
//    @Published
//    var editedEvent: RelativeEvent? = nil
    
    var location: CLLocationCoordinate2D
    
    init (context: NSManagedObjectContext, location: CLLocationCoordinate2D, eventStore: EventStore) {
        self.context = context
        self.location = location
        self.eventStore = eventStore
    }
    
    func duration(event: RelativeEvent) -> Double {
        let prayerCalculator: PrayerCalculator? = PrayerCalculator(location: location, date: Date())
        return event.duration(time: prayerCalculator!.time)
    }
    
    func adhanTime(_ event: RelativeEvent) -> Date? {
        let prayerCalculator: PrayerCalculator? = PrayerCalculator(location: location, date: Date())
        return prayerCalculator?.time(of: event.startTimeName)
    }
    
    func adhanTimeText(_ event: RelativeEvent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let datetime = adhanTime(event)!
        return dateFormatter.string(from: datetime)
    }
    

    // MARK: Intent(s)
    
//    var addingNewEvent: Bool {
//        get { editEventViewModel != nil }
//        set {
//            if newValue == false {
//                editEventViewModel = nil
//                context.rollback()
//            }
//        }
//    }

    @discardableResult
    func fetch() -> [RelativeEvent] {
        let request = NSFetchRequest<RelativeEvent>(entityName: "RelativeEvent")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \RelativeEvent.startRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.endRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.start, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.end, ascending: true),
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
//        editedEvent = RelativeEvent.create(context, "")
        // Connect the event to start prayer time only fo now
//        editedEvent.startRelativeTo = allcatableSlot.startRelativeTo
//        editedEvent.endRelativeTo = allcatableSlot.startRelativeTo
//        let event = RelativeEvent.create(context, "3333333").startAt(-30*60, relativeTo: .fajr).endAt(0, relativeTo: .fajr)

        editEventViewModel = EditEventViewModel(nil, availableSlot: allcatableSlot, location: location, context: context, eventStore: eventStore)
        addingNewEvent = true
    }
    
    func edit(event: RelativeEvent) {
        editEventViewModel = EditEventViewModel(event, availableSlot: expandAllocatableSlot(event), location: location, context: context, eventStore: eventStore)
        editingEvent = true
    }
    
    func cancelEditing() {
        editingEvent = false
        addingNewEvent = false
        context.rollback()
        fetch()
        editEventViewModel = nil
    }
    
    func doneEditing() {
        addingNewEvent = false
        editingEvent = false
        editEventViewModel = nil
        fetch()
    }
    
    func deleteEvent(indexSet: IndexSet) {
        indexSet.map { relativeEvents[$0] }.forEach(eventStore.delete)
        indexSet.map { relativeEvents[$0] }.forEach(context.delete)
        try? context.save()
        indexSet.forEach { relativeEvents.remove(at: $0) }
    }
    
    func deleteEvent(event: RelativeEvent) {
        eventStore.delete(event)
        context.delete(event)
        try? context.save()
        doneEditing()
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
    
    func deleteCalendar() {
        try! eventStore.ekEventStore.removeCalendar(eventStore.muslimCalender, commit: true)
    }
    
    func expandAllocatableSlot(_ event: RelativeEvent) -> RelativeEvent { 
        return event.expandAllocatableSlot(context: context)
    }
    
    func syncCalendar() {
        let prayerCalculator: PrayerCalculator = PrayerCalculator(location: location, date: Date())!
        relativeEvents.filter({ event in !(event.isAdhan || event.isAllocatable) }).forEach { event in
            eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator, repeats: true)
        }
        try! context.save()
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
