//
//  Zip2Event.swift
//  MuslimCalender (iOS)
//
//  Created by Mustafa Abdelhamıd on 20.08.2022.
//

import Foundation
import CoreData

struct Zip2Event {
    let index: Int
    let event: RelativeEvent
    let nextEvent: RelativeEvent
    let prayerCalculation: PrayerCalculation
    
    var availableTime: TimeInterval? {
        let interval = nextEvent.startDate(time: prayerCalculation.time).timeIntervalSince(event.endDate(time: prayerCalculation.time))
        if interval <= 0 {
            return nil
        }
        return interval
    }
}

extension Zip2Event: Identifiable {
    var id: RelativeEvent { self.event }
}
