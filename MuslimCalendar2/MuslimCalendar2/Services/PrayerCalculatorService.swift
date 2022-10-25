//
//  PrayerCalculatorService.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 25.10.2022.
//

import SwiftUI
import CoreLocation

class PrayerCalculatorService: ObservableObject {
    @Published
    var location: CLLocation?
    
    @Published
    var day: WeekDay?
    
    @Published
    var prayerCalculation: PrayerCalculation = PrayerCalculation.preview
    
    // MARK: - Intent(s)
    func updateLocation(_ location: CLLocation) {
        self.location = location
    }
    
    func updateDay(_ day: WeekDay) {
        self.day = day
    }
}
