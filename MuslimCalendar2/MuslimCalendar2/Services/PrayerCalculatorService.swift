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
            if let calculation = self?.calculate(forDay: date, forLocation: location) {
                self?.prayerCalculation = calculation
            }
        }.store(in: &cancellables)
    }

    func calculate(forDay day: Date, forLocation location: CLLocation) -> PrayerCalculation? {
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: day)
        let coordinates = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        //TODO: add this to user defaults
        var params = CalculationMethod.turkey.params
        params.method = .turkey

        if let prayerTimes = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
            return PrayerCalculation.createFromPrayerTimes(prayerTimes, location: location, day: day, params: params)
        } else {
            return nil
        }
    }
    
    // MARK: - Intent(s)
    func updateLocation(_ location: CLLocation) {
        self.location = location
    }
    
    func updateDay(_ day: WeekDay) {
        self.day = day
    }
}
