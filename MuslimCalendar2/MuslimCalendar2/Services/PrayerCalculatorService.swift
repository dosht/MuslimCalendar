//
//  PrayerCalculatorService.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 25.10.2022.
//

import SwiftUI
import CoreLocation
import Combine
import Adhan

class PrayerCalculatorService: ObservableObject {
    @Published
    var location: CLLocation?
    
    @Published
    var day: WeekDay?
    
    @Published
    var prayerCalculation: PrayerCalculation = PrayerCalculation.preview
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $location
            .combineLatest($day)
            .sink { [weak self] location, day in
                guard let location = location else { return }
                let date = day.map(Date().this) ?? Date()
                if let calculation = calculatePrayerTimes(forDay: date, forLocation: location) {
                    self?.prayerCalculation = calculation
                }
            }.store(in: &cancellables)
    }
    
    // MARK: - Intent(s)
    func updateLocation(_ location: CLLocation) {
        self.location = location
    }
    
    func updateDay(_ day: WeekDay) {
        self.day = day
    }
}
