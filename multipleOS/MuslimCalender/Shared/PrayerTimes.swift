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

enum PrayerName: String, CaseIterable {
    case fajr = "Fajr",
         sunrise = "Sunrise ☀️",
         dhur = "Dhur",
         asr = "Asr",
         maghrib = "Maghrib",
         isha = "Isha"
}

struct Prayer {
    var params: CalculationParameters
    let adhanPrayerTimes: PrayerTimes
    let coordinates: Coordinates
    let date: DateComponents
    
    init?(location: CLLocationCoordinate2D, date: Date) {
        self.coordinates = Coordinates(latitude: location.latitude, longitude: location.longitude)
        params = CalculationMethod.turkey.params
        params.madhab = .shafi
        params.method = .turkey
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        self.date = cal.dateComponents([.year, .month, .day], from: date)
        if let adhanPrayerTimes = PrayerTimes(coordinates: coordinates, date: self.date, calculationParameters: params) {
            self.adhanPrayerTimes = adhanPrayerTimes
        } else {
            return nil
        }
    }
    
    var rules: [(PrayerName, Date)] {
        get {
            return [
                (.fajr, adhanPrayerTimes.fajr),
                (.sunrise, adhanPrayerTimes.sunrise),
                (.dhur, adhanPrayerTimes.dhuhr),
                (.asr, adhanPrayerTimes.asr),
                (.maghrib, adhanPrayerTimes.maghrib),
                (.isha, adhanPrayerTimes.isha)
            ]
        }
    }
}
