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
        index.map{zip2Events[$0]}?.nextEvent
    }
    
    @Published
    var showExtraOptions: EventToolbarOptions? = .position
    
    @Published
    var position: Position = .begnning {
        didSet {
            if position == oldValue {
                return
            }
            if oldValue == .full {
                duration = Date().startOfDay.addingTimeInterval(30*60)
            }
            if timeInterval == 0 && position != .full {
                return
            }
            updatePosition(newPosition: position)
        }
    }
    
    @Published
    var duration: Date = Date().startOfDay {
        didSet {
            if event != nil {
                updateDuration(newDuration: duration)
            }
        }
    }
     
    var timeInterval: TimeInterval { duration.timeIntervalSince(Date().startOfDay) }
    
    init(zip2Events: Binding<[Zip2Event]>, index: FocusState<Int?>.Binding) {
        self._zip2Events = zip2Events
        self._index = index
        if index.wrappedValue != nil {
            position = getPosition()
            duration = getDuration()
        }
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
        var timeInterval: TimeInterval = 0
        if let event = event {
            timeInterval = abs(event.end - event.start)
        }
        return Date().startOfDay.addingTimeInterval(timeInterval)
    }
    
//    func getDuration() -> Date {
//        var timeInterval: TimeInterval = 30*60
//        if let start = event?.start, let end = event?.end {
//            switch position {
//            case .begnning:
//                timeInterval = end
//            case .end:
//                timeInterval = -start
//            case .full: () // Doesn't apply here
//            }
//        }
//        return Date().startOfDay.addingTimeInterval(timeInterval)
//    }
    
    func updatePosition(newPosition position: Position) {
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
    
    func updateDuration(newDuration duration: Date) {
        print("Updating duration: \(duration)")
        let t: TimeInterval = duration.timeIntervalSince(Date().startOfDay)
        if position == .begnning {
            event?.end = (event?.start ?? 0) + t
        }
        if position == .end {
            event?.start = (event?.end ?? 0) - t
        }
    }
}
