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
                return PrayerCalculation(prayerTimes: prayerTimes, location: location, day: day, params: params)
            } else {
                return nil
            }
        } else {
            return  nil
        }
    }
}

struct PrayerCalculation {
    //TODO: Remove prayerTimes for testing
    private let prayerTimes: PrayerTimes
    let location: CLLocation
    let day: Date
    let params: CalculationParameters
    
    var fajr: Date { get { prayerTimes.fajr } }
    var sunrise: Date { get { prayerTimes.sunrise } }
    var dhuhr: Date { get { prayerTimes.dhuhr } }
    var asr: Date { get { prayerTimes.asr } }
    var maghrib: Date { get { prayerTimes.maghrib } }
    var isha: Date { get { prayerTimes.isha } }
    
    var midnight: Date { get { day.startOfDay } }
    var endOfDay: Date { get { day.endOfDay } }
    
    init(prayerTimes: PrayerTimes, location: CLLocation, day: Date, params: CalculationParameters) {
        self.prayerTimes = prayerTimes
        self.location = location
        self.day = day
        self.params = params
    }

    func time(of timeName: TimeName) -> Date {
        switch timeName {
        case .midnight:
            return self.midnight
        case .fajr:
            return self.fajr
        case .sunrise:
            return self.sunrise
        case .dhur:
            return self.dhuhr
        case .asr:
            return self.asr
        case .maghrib:
            return self.maghrib
        case .isha:
            return self.isha
        case .endOfDay:
            return self.endOfDay
        }
    }
}

enum TimeName: String, CaseIterable {
    case midnight = "Midnight",
         fajr = "Fajr",
         sunrise = "Sunrise ☀️",
         dhur = "Dhur",
         asr = "Asr",
         maghrib = "Maghrib",
         isha = "Isha",
         endOfDay = "End of Day"
}

extension TimeName: Identifiable {
    var id: RawValue { rawValue }
    var intValue: Int16 {
        switch self {
        case .midnight: return 0
        case .fajr: return 1
        case .sunrise: return 2
        case .dhur: return 3
        case .asr: return 4
        case .maghrib: return 5
        case .isha: return 6
        case .endOfDay: return 7
        }
    }
}
