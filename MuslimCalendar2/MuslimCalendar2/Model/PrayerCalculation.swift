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

func calculatePrayerTimes(forDay day: Date, forLocation location: CLLocation) -> PrayerCalculation? {
    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
    let date = cal.dateComponents([.year, .month, .day], from: day)
    let coordinates = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

    //TODO: add this to user defaults
    var params = CalculationMethod.turkey.params

    if let prayerTimes = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
        return PrayerCalculation.createFromPrayerTimes(prayerTimes, location: location, day: day, params: params)
    } else {
        return nil
    }
}

extension PrayerCalculation {
    func calculate(for day: Date) -> PrayerCalculation? {
        calculatePrayerTimes(forDay: day, forLocation: location)
    }
}

extension PrayerCalculation {
    static var preview: PrayerCalculation = PrayerCalculation(
        location: PrayerCalculation.previewLocation,
        day: Date(timeString: "00:00"),
        params: PrayerCalculation.previewParameters,
        fajr: Date(timeString: "03:50"),
        sunrise: Date(timeString: "06:00"),
        dhuhr: Date(timeString: "13:00"),
        asr: Date(timeString: "16:30"),
        maghrib: Date(timeString: "20:15"),
        isha: Date(timeString: "21:50")
    )
    
    static var previewParameters: CalculationParameters = CalculationMethod.turkey.params
    
    static var previewLocation: CLLocation = CLLocation(latitude: 21.4361607, longitude: 39.9164145)
}
