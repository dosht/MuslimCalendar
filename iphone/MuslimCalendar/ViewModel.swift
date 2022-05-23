//
//  ViewModel.swift
//  MuslimCalendar
//
//  Created by Mustafa Abdelhamıd on 19.03.2022.
//

import SwiftUI
import EventKit
import Adhan
import KVKCalendar

class ViewModel: ObservableObject {
    @Published private(set) var model = createModel()
    @Published var chosenEvent: Event?
    
    private static func createModel() -> Model {
        var model = Model()
        model.initPrayerTimes()
        model.loadPlan()
        model.applyPlan()
        // TODO: Move BGT schedule to a better place
        registerUpdateCalendarBGT()
        scheduleUpdateCalendarBGT()
        return model
    }
    
    var events: [Event] {
        get { model.events }
        set { model.events = newValue }
    }
    
    var willAddEvent: Bool {
        get { chosenEvent != nil }
        set { if newValue == false { chosenEvent = nil } }
    }
    
    // MARK: Intent(s)
    func chooseEvent(_ event: Event) {
        chosenEvent = event
    }
    
    func deleteChoosenEvent() {
        if let event = chosenEvent {
            model.disconnect(event)
            model.deleteEvent(event)
            model.savePlan()
        }
    }
    
    func addEvent(_ name: String, _ duration: TimeInterval, after: Bool) {
        var event: Event?
        if let chosenEvent = chosenEvent {
            if after {
                event = chosenEvent.eventAfter(name, for: duration)
            } else {
                event = chosenEvent.eventBefore(name, for: duration)
            }
            if let event = event {
                model.addEvent(event)
                model.connect(event, with: chosenEvent, isAfter: after, duration: duration)
                model.savePlan()
            }
        }
    }
}
