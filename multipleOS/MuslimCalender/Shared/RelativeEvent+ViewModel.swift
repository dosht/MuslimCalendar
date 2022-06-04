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
    
    @Published
    var relativeEvents: [RelativeEvent] = []
    
    var location: CLLocationCoordinate2D
    
    init (context: NSManagedObjectContext, location: CLLocationCoordinate2D) {
        self.context = context
        self.location = location
    }
    
    func fetch() {
        let request = NSFetchRequest<RelativeEvent>(entityName: "RelativeEvent")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \RelativeEvent.startRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.start, ascending: true)
        ]
        do {
//            for e in try context.fetch(request){
//                context.delete(e)
//            }
//            try context.save()
            relativeEvents = try context.fetch(request)
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
    }
    
    func deleteEvent(indexSet: IndexSet) {
        
    }
    
    func duration(event: RelativeEvent) -> Double {
        let prayerCalculator: PrayerCalculator? = PrayerCalculator(location: location, date: Date())
        return event.duration(time: prayerCalculator!.time)
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
    
}

extension RelativeEvent {
    var isAfter: Bool {
        start >= 0
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
