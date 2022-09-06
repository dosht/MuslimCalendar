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
import Combine

class ScheduleViewModel: ObservableObject {
    // MARK: - Dependencies
    @Injected var relativeEventRepository: RelativeEventRepository
    @Injected private var eventKitRepository: EventKitRepository
    @Injected private var locationManager: LocationService
    @Injected private var prayerCalculationService: PrayerCalculatorService
   
    // MARK: - Publishers
    @Published
    var relativeEvents: [RelativeEvent] = []
    
    var zipEvents: [Zip2Event] {
        get {
            if let prayerCalculation = prayerCalculation {
                return zip(relativeEvents.dropLast(), relativeEvents.dropFirst()).enumerated().map { (i, e) in
                    Zip2Event(index: i, event: e.0, nextEvent: e.1, prayerCalculation: prayerCalculation)
                }
            } else {
                return [Zip2Event]()
            }
        } set {}
    }
    
    private var subscribers = Set<AnyCancellable>()
    
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
    
//    @Published
//    var location: CLLocationCoordinate2D = LocationService.defaultCoordinate
    
    @Published
    var focusedIndex: Int?
    
    @Published
    var focusedZip2Event: Zip2Event?
    
    @Published
    var showToolbar: Bool = false
    
    @Published
    var prayerCalculation: PrayerCalculation?
    
    init () {
//        locationManager.$lastCoordinate.assign(to: &$location)
        prayerCalculationService.$prayerCalculation.assign(to: &$prayerCalculation)
        relativeEventRepository.$relativeEvents.assign(to: &$relativeEvents)
        $focusedIndex
            .receive(on: DispatchQueue.main)
            .sink { [self] in
                if let index = $0 {
                    showToolbar = true
                    focusedZip2Event = zipEvents[index]
                } else {
                    focusedZip2Event = nil
                    showToolbar = false
                }
            }
            .store(in: &subscribers)
    }
    
    func duration(event: RelativeEvent) -> Double {
        if let prayerCalculation = prayerCalculation {
            return event.duration(time: prayerCalculation.time)
        } else {
            return 0
        }
    }
    
    func adhanTime(_ event: RelativeEvent) -> Date {
        if let prayerCalculation = prayerCalculation {
            return prayerCalculation.time(of: event.startTimeName)
        } else {
            return Date()
        }
    }
    
    func adhanTimeText(_ event: RelativeEvent) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let datetime = adhanTime(event)
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
    
    func addNewEventInline(_ zip2Event: Zip2Event) {
        let newEvent = relativeEventRepository
            .newEvent()
            .startAt(zip2Event.event.end, relativeTo: zip2Event.event.endTimeName)
            .endAt(zip2Event.event.end + 30*60, relativeTo: zip2Event.event.endTimeName)
        let newIndex = zip2Event.index + 1
        relativeEvents.insert(newEvent, at: newIndex)
        focusedIndex = newIndex
    }
    
    func save() {
        relativeEventRepository.save()
        if let index = focusedIndex {
            let event = relativeEvents[index]
            let ekEvent = eventKitRepository.createOrUpdate(event, prayerCalculation: prayerCalculation!, repeats: true)
            if event.ekEventIdentifier == nil {
                event.ekEventIdentifier = ekEvent.eventIdentifier
                relativeEventRepository.save()
            }
        }
        focusedIndex = nil
    }
    
    func chooseAllocatableSlot(allcatableSlot: RelativeEvent) {
        chosenAllocatableSlot = allcatableSlot
//        editedEvent = RelativeEvent.create(context, "")
        // Connect the event to start prayer time only fo now
//        editedEvent.startRelativeTo = allcatableSlot.startRelativeTo
//        editedEvent.endRelativeTo = allcatableSlot.startRelativeTo
//        let event = RelativeEvent.create(context, "3333333").startAt(-30*60, relativeTo: .fajr).endAt(0, relativeTo: .fajr)

        if let prayerCalculation = prayerCalculation {
            editEventViewModel = EventEditorViewModel(nil, availableSlot: allcatableSlot, prayerCalculation: prayerCalculation)
            addingNewEvent = true
        }
    }
    
    func edit(event: RelativeEvent) {
        if let prayerCalculation = prayerCalculation {
            editEventViewModel = EventEditorViewModel(event, availableSlot: expandAllocatableSlot(event), prayerCalculation: prayerCalculation)
            editingEvent = true
        }
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
        let events = indexSet.map { relativeEvents[$0+1] }
        indexSet.forEach { relativeEvents.remove(at: $0) }
        events.map{$0}.forEach(deleteEvent)
    }
    
    func deleteEvent(event: RelativeEvent) {
//        expandAllocatableSlot(event)
        eventKitRepository.delete(event)
        relativeEventRepository.deleteEvent(event: event)
        focusedIndex = nil
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
        if let prayerCalculation = prayerCalculation {
            relativeEvents.filter({ event in !(event.isAdhan || event.isAllocatable) }).forEach { event in
                eventKitRepository.delete(event)
                let ekEvent = eventKitRepository.createOrUpdate(event, prayerCalculation: prayerCalculation, repeats: true)
                event.ekEventIdentifier = ekEvent.eventIdentifier
            }
            relativeEventRepository.save()
        }
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
        if result.isEmpty {
            return "N/A"
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
