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
import Resolver

class ScheduleViewModel: ObservableObject {
    // MARK: - Dependencies
    @Injected private var relativeEventRepository: RelativeEventRepository
    @Injected private var eventKitRepository: EventKitRepository
    @Injected private var locationManager: LocationManager
   
    // MARK: - Publishers
    @Published
    var relativeEvents: [RelativeEvent] = []
    
    @Published
    var addingNewEvent: Bool = false
    
    @Published
    var editingEvent: Bool = false
    
    @Published
    var editEventViewModel: EventEditorViewModel? = nil
//
//    @Published
    var chosenAllocatableSlot: RelativeEvent? = nil
//
//    @Published
//    var editedEvent: RelativeEvent? = nil
    
    @Published
    var location: CLLocationCoordinate2D = LocationManager.defaultCoordinate
    
    init () {
        locationManager.$lastCoordinate.assign(to: &$location)
        relativeEventRepository.$relativeEvents.assign(to: &$relativeEvents)
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
    

    // MARK: - Intent(s)
    
//    var addingNewEvent: Bool {
//        get { editEventViewModel != nil }
//        set {
//            if newValue == false {
//                editEventViewModel = nil
//                context.rollback()
//            }
//        }
//    }

    func fetch() {
        relativeEventRepository.fetch()
    }
    
    func chooseAllocatableSlot(allcatableSlot: RelativeEvent) {
        chosenAllocatableSlot = allcatableSlot
//        editedEvent = RelativeEvent.create(context, "")
        // Connect the event to start prayer time only fo now
//        editedEvent.startRelativeTo = allcatableSlot.startRelativeTo
//        editedEvent.endRelativeTo = allcatableSlot.startRelativeTo
//        let event = RelativeEvent.create(context, "3333333").startAt(-30*60, relativeTo: .fajr).endAt(0, relativeTo: .fajr)

        editEventViewModel = EventEditorViewModel(nil, availableSlot: allcatableSlot, location: location)
        addingNewEvent = true
    }
    
    func edit(event: RelativeEvent) {
        editEventViewModel = EventEditorViewModel(event, availableSlot: expandAllocatableSlot(event), location: location)
        editingEvent = true
    }
    
    func cancelEditing() {
        editingEvent = false
        addingNewEvent = false
        relativeEventRepository.rollback()
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
        let events = indexSet.map { relativeEvents[$0] }
        print(events)
        indexSet.forEach { relativeEvents.remove(at: $0) }
        events.forEach(deleteEvent)
    }
    
    func deleteEvent(event: RelativeEvent) {
        expandAllocatableSlot(event)
        eventKitRepository.delete(event)
        relativeEventRepository.deleteEvent(event: event)
    }
    
    
    func deleteAll() {
        relativeEventRepository.deleteAll()
    }
    
    func deleteCalendar() {
        try! eventKitRepository.ekEventStore.removeCalendar(eventKitRepository.muslimCalender, commit: true)
    }
    
    func expandAllocatableSlot(_ event: RelativeEvent) -> RelativeEvent {
        //TODO: Remove creating allocatable event
        return relativeEventRepository.expandAllocatableSlot(event)
    }
    
    func syncCalendar() {
        let prayerCalculator: PrayerCalculator = PrayerCalculator(location: location, date: Date())!
        relativeEvents.filter({ event in !(event.isAdhan || event.isAllocatable) }).forEach { event in
            eventKitRepository.delete(event)
            let ekEvent = eventKitRepository.createOrUpdate(event, on: Date().startOfDay, prayerCalculator: prayerCalculator, repeats: true)
            event.ekEventIdentifier = ekEvent.eventIdentifier
        }
        relativeEventRepository.save()
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
