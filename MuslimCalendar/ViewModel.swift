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
        model.init_prayer_times()
        return model
    }
    
    var events: [Event] {
        get { model.events }
        set { model.events = newValue }
    }
    
    var willAddEvent: Bool {
        chosenEvent != nil
    }
    
    // MARK: Intent(s)
    func chooseEvent(_ event: Event) {
        chosenEvent = event
    }
    
    func addEvent(_ name: String, _ duration: TimeInterval, after: Bool) {
        var event: Event?
        if let chosenEvent = chosenEvent {
            if after {
                event = chosenEvent.eventAfter(name, for: duration)
            } else {
                event = chosenEvent.eventBefore(name, for: duration)
            }
        }
        if let event = event {
            events.append(event)
        }
    }
}
