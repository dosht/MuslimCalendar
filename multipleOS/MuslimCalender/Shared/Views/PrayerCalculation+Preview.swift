//
//  PrayerCalculation+Preview.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 21.08.2022.
//

import Foundation
import Adhan

extension PrayerCalculation {
    //TODO: make this normal data struct
    static var preview: PrayerCalculation = PrayerCalculation(
        location: LocationService.defaultLocation,
        day: Date(),
        params: PrayerCalculation.previewParameters,
        fajr: Date().advancedBy(hour: 3, minute: 50),
        sunrise: Date().advancedBy(hour: 6),
        dhuhr: Date().advancedBy(hour: 13),
        asr: Date().advancedBy(hour: 16, minute: 30),
        maghrib: Date().advancedBy(hour: 20, minute: 15),
        isha: Date().advancedBy(hour: 21, minute: 50)
    )
    
    static var previewParameters: CalculationParameters = CalculationMethod.turkey.params
}
