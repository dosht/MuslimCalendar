//
//  Model.swift
//  MuslimCalendar
//
//  Created by Mustafa Abdelhamıd on 19.03.2022.
//

import Foundation
import EventKit
import Adhan
import KVKCalendar

struct Model {
    var events: [Event] = []
    
    mutating func init_prayer_times() {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        // 40,71910° N, 29,78066° E
        let coordinates = Coordinates(latitude: 40.71910, longitude: 29.78066)
        var params = CalculationMethod.turkey.params
        params.madhab = .shafi
        params.method = .turkey
        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
            var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
            print(localTimeZoneIdentifier)
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.timeZone = TimeZone(identifier: localTimeZoneIdentifier)!

            print("fajr \(formatter.string(from: prayers.fajr))")
            print("sunrise \(formatter.string(from: prayers.sunrise))")
            print("dhuhr \(formatter.string(from: prayers.dhuhr))")
            print("asr \(formatter.string(from: prayers.asr))")
            print("maghrib \(formatter.string(from: prayers.maghrib))")
            print("isha \(formatter.string(from: prayers.isha))")
            
            events.append(Event.create(ID: "\(Times.fajr)", text: "Fajr", duration: 60*30, start: prayers.fajr))
            events.append(Event.create(ID: "\(Times.sunrise)", text: "Sunrise ☀️", duration: 60*30, start: prayers.sunrise))
            events.append(Event.create(ID: "\(Times.dhur)", text: "Dhur", duration: 60*30, start: prayers.dhuhr))
            events.append(Event.create(ID: "\(Times.asr)", text: "Asr", duration: 60*30, start: prayers.asr))
            events.append(Event.create(ID: "\(Times.maghrib)", text: "Maghrib ", duration: 60*30, start: prayers.maghrib))
            events.append(Event.create(ID: "\(Times.isha)", text: "Isha", duration: 60*30, start: prayers.isha))
        }
    }
    
    mutating func addEvent(_ event: Event) {
        events.append(event)
    }
}

enum Times {
    case fajr, sunrise, dhur, asr, maghrib, isha
}

extension Event {
    public static func create(ID: String, text: String, duration: TimeInterval, start: Date) -> Event {
        var event = Event(ID: ID)
        event.text = text
        event.start = start
        event.end = Date(timeInterval: duration, since: start)
        event.isAllDay = false
        event.isContainsFile = false
        event.recurringType = .none
        return event
    }
    func eventAfter(_ name: String, for duration: TimeInterval) -> Event {
        Event.create(ID: name, text: name, duration: duration, start: self.end)
    }
    
    func eventBefore(_ name: String, for duration: TimeInterval) -> Event {
        Event.create(ID: name, text: name, duration: duration, start: Date(timeInterval: -duration, since: start))
    }
}
