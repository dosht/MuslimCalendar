//
//  EditEvent+ViewModel.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 10.06.2022.
//

import Foundation
import SwiftUI
import CoreLocation
import CoreData
import Resolver

class EditEventViewModel: ObservableObject {
    //MARK: - Dependencies
    @Injected private var relativeEventRepository: RelativeEventRepository
    
    private let eventStore: EventStore
    
    @Published
    var event: RelativeEvent
    
    @Published
    var alloc: RelativeEvent
    
    private var prayerCalculator: PrayerCalculator
    
    init(_ event: RelativeEvent?, availableSlot alloc: RelativeEvent, location: CLLocationCoordinate2D, eventStore: EventStore  = EventStore()) {
        self.event = event ?? _relativeEventRepository.wrappedValue.newEvent()
            .startAt(alloc.start, relativeTo: alloc.startTimeName)
            .endAt(alloc.start + 30*60, relativeTo: alloc.startTimeName)
        self.alloc = alloc
        prayerCalculator = PrayerCalculator(location: location, date: Date())!
        self.eventStore = eventStore
        if let event = event {
            self.eventDuration = event.duration(time: prayerCalculator.time)
        } else {
            self.eventDuration = 30 * 60
        }
    }
    
    var isNew: Bool { event.isInserted }
    
    @Published
    var showDuration: Bool = true
    
    var allocationType: AllocationType {
        get {
            if event.startTimeName == alloc.startTimeName && event.endTimeName == alloc.endTimeName {
                return .full
            }
            if event.startTimeName == alloc.endTimeName {
                return .end
            }
            return .begnning
        }
        set {
            switch newValue {
            case .begnning:
                event.start = alloc.start
                event.end = eventDuration
                event.startTimeName = alloc.startTimeName
                event.endTimeName = alloc.startTimeName
                showDuration = true
            case .end:
                event.start = alloc.end - eventDuration
                event.end = alloc.end
                event.startTimeName = alloc.endTimeName
                event.endTimeName = alloc.endTimeName
                showDuration = true
            case .full:
                event.start = alloc.start
                event.end = alloc.end
                event.startTimeName = alloc.startTimeName
                event.endTimeName = alloc.endTimeName
                showDuration = false
            }
        }
    }
    
    enum AllocationType: String, CaseIterable, Identifiable {
        var id: Self { self }
        
        case begnning = "Begnning",
             end = "End",
             full = "All"
    }
    
    @Published
    var eventDuration: TimeInterval {
        didSet {
            event.setDuration(eventDuration, allocatableSlot: alloc, allocationType: allocationType)
        }
    }
    
    func duration(event: RelativeEvent) -> Double {
        return event.duration(time: prayerCalculator.time)
    }
      
    // MARK: Intent(s)
    
    func save() {
//        alloc.start += duration(event: event)
        alloc.allocate(newEvent: event)
//        if duration(event: alloc) == 0 {
//            context.delete(alloc)
//        }
        relativeEventRepository.save()
        let ekEvent = eventStore.createOrUpdate(event, on: Date(), prayerCalculator: prayerCalculator, repeats: true)
        if event.ekEventIdentifier == nil {
            event.ekEventIdentifier = ekEvent.eventIdentifier
            relativeEventRepository.save()
        }
    }
    
    func cancel() {
        relativeEventRepository.rollback()
            relativeEventRepository.save()
    }
    
    func delete() {
        relativeEventRepository.deleteEvent(event: event)
    }

}

extension RelativeEvent {
    
    @discardableResult
    func setDuration(_ duration: TimeInterval, allocatableSlot alloc: RelativeEvent, allocationType: EditEventViewModel.AllocationType) -> RelativeEvent {
        switch allocationType {
        case .begnning:
            self.startTimeName = alloc.startTimeName
            self.endTimeName = alloc.startTimeName
            self.start = alloc.start
            self.end = alloc.start + duration
        case .end:
            self.startTimeName = alloc.endTimeName
            self.endTimeName = alloc.endTimeName
            self.start = alloc.end - duration
            self.end = alloc.end
        case .full:
            self.startTimeName = alloc.startTimeName
            self.endTimeName = alloc.endTimeName
            self.start = alloc.start
            self.end = alloc.end
        }
        return self
    }
}
