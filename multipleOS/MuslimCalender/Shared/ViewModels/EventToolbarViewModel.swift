//
//  EventToolbarViewModel.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 28.08.2022.
//

import SwiftUI

class EventToolbarViewModel: ObservableObject {
    @Binding
    var zip2Events: [Zip2Event]
    
    @FocusState.Binding
    var index: Int?
    
    var event: RelativeEvent? {
        index.map{zip2Events[$0]}?.event
    }
    
    var previousEvent: RelativeEvent? {
        index.map{zip2Events[$0-1]}?.event
    }
    
    var nextEvent: RelativeEvent? {
        index.map{zip2Events[$0+1]}?.event
    }
    
    @Published
    var showExtraOptions: EventToolbarOptions? = .position
    
    @Published
    var position: Position = .begnning {
        didSet {
            if position != oldValue {
                updatePosition()
            }
        }
    }
    
    @Published
    var duration: Date = Date().startOfDay.addingTimeInterval(30*60)
     
    init(zip2Events: Binding<[Zip2Event]>, index: FocusState<Int?>.Binding) {
        self._zip2Events = zip2Events
        self._index = index
        position = getPosition()
        duration = getDuration()
    }
    
    enum Position: String, CaseIterable, Identifiable {
        var id: Self { self }
        
        case begnning = "Begnning",
             end = "End",
             full = "All"
    }

    func getPosition() -> Position {
        if let firstEvent = previousEvent, let secondEvent = nextEvent {
            switch (event?.startRelativeTo, event?.endRelativeTo) {
            case (firstEvent.endRelativeTo, secondEvent.startRelativeTo): return .full
            case (firstEvent.endRelativeTo, firstEvent.endRelativeTo): return .begnning
            case (secondEvent.startRelativeTo, secondEvent.startRelativeTo): return .end
            default:
                print("Unexpected relativeTo config! \(String(describing: event))")
            }
        }
        return .begnning
    }
    
    func getDuration() -> Date {
        if let start = event?.start, let end = event?.end {
            print("end: \(end), start: \(start)")
            return Date().startOfDay.addingTimeInterval(30*60)
        } else {
            return Date().startOfDay.addingTimeInterval(30*60)
        }
    }
    
    func updatePosition() {
        if let firstEvent = previousEvent, let secondEvent = nextEvent {
            switch position {
            case .begnning:
                event?.startAt(firstEvent.end, relativeTo: firstEvent.endTimeName)
                event?.endAt(firstEvent.end + duration.timeIntervalSince(Date().startOfDay), relativeTo: firstEvent.endTimeName)
            case .end:
                event?.startAt(secondEvent.start - duration.timeIntervalSince(Date().startOfDay), relativeTo: secondEvent.startTimeName)
                event?.endAt(secondEvent.start, relativeTo: secondEvent.startTimeName)
            case .full:
                event?.startAt(firstEvent.end, relativeTo: firstEvent.endTimeName)
                event?.endAt(secondEvent.start, relativeTo: secondEvent.startTimeName)
            }
        }
    }
}
