//
//  PrayerTimes.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 21.05.2022.
//

import Foundation
import CoreLocation
import CoreData

import Adhan

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

struct PrayerCalculator {
    var params: CalculationParameters
    let adhanPrayerTimes: PrayerTimes
    let coordinates: Coordinates
    let location: CLLocationCoordinate2D
    let date: DateComponents
    
    init?(location: CLLocationCoordinate2D, date: Date) {
        self.location = location
        self.coordinates = Coordinates(latitude: location.latitude, longitude: location.longitude)
        
//        params = CalculationMethod.turkey.params
//        params.method = .turkey
        
        params = CalculationMethod.egyptian.params
        params.madhab = .shafi
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        self.date = cal.dateComponents([.year, .month, .day], from: date)
        if let adhanPrayerTimes = PrayerTimes(coordinates: coordinates, date: self.date, calculationParameters: params) {
            self.adhanPrayerTimes = adhanPrayerTimes
        } else {
            return nil
        }
    }
    
    func time(of timeName: TimeName) -> Date {
        switch timeName {
        case .midnight:
            return Date().startOfDay
        case .fajr:
            return adhanPrayerTimes.fajr
        case .sunrise:
            return adhanPrayerTimes.sunrise
        case .dhur:
            return adhanPrayerTimes.dhuhr
        case .asr:
            return adhanPrayerTimes.asr
        case .maghrib:
            return adhanPrayerTimes.maghrib
        case .isha:
            return adhanPrayerTimes.isha
        case .endOfDay:
            return Date().endOfDay
        }
    }
}
