//
//  PrayerCalculation.swift
//  MuslimCalender (iOS)
//
//  Created by Mustafa Abdelhamıd on 22.08.2022.
//

import Foundation
import Adhan
import CoreLocation

struct PrayerCalculation {
    let location: CLLocation
    let day: Date
    let params: CalculationParameters
    
    let fajr: Date
    let sunrise: Date
    let dhuhr: Date
    let asr: Date
    let maghrib: Date
    let isha: Date
    
    var midnight: Date { get { day.startOfDay } }
    var endOfDay: Date { get { day.endOfDay } }
    
    static func createFromPrayerTimes(_ prayerTimes: PrayerTimes, location: CLLocation, day: Date, params: CalculationParameters) -> PrayerCalculation {
        return PrayerCalculation(
            location: location,
            day: day,
            params: params,
            fajr: prayerTimes.fajr,
            sunrise: prayerTimes.sunrise,
            dhuhr: prayerTimes.dhuhr,
            asr: prayerTimes.asr,
            maghrib: prayerTimes.maghrib,
            isha: prayerTimes.isha
        )
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
