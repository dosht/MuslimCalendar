//
//  PrayerTimes.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 21.05.2022.
//

import Foundation
import CoreLocation
import CoreData
import Resolver
import Adhan
import Combine

class PrayerCalculatorService: ObservableObject {
    // MARK: - Dependencies
    @Injected
    var locationService: LocationService
    
    // MARK: - Publishers
    @Published
    private(set) var prayerCalculation: PrayerCalculation? = nil
    
    @Published
    var day: Date = Date()
    
    private var subscribers = Set<AnyCancellable>()
    
    init() {
        locationService.$lastLocation
            .receive(on: DispatchQueue.main)
            .sink { [self] in prayerCalculation = calculate(forLocation: $0) }
            .store(in: &subscribers)
    }
    
    func calculate(forDay day: Date? = nil, forLocation location: CLLocation? = nil) -> PrayerCalculation? {
        if let location = location {
            let day = day ?? self.day
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
        } else {
            return  nil
        }
    }
}
