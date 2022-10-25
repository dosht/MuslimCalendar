//
//  PrayerTimes+ScheduleItem.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 25.10.2022.
//

import Foundation

extension ScheduleItem {
    static func prayerScheduleItems(prayerCalculation: PrayerCalculation) -> [ScheduleItem] {
        TimeName
            .allCases
            .map { timeName in
                ScheduleItem(title: timeName.rawValue, startTime: prayerCalculation.time(of: timeName), duration: 0, type: .prayer)
            }
    }
    static var prayerRealisticSample: [ScheduleItem] {
        ScheduleItem.prayerScheduleItems(prayerCalculation: PrayerCalculation.preview)
    }
}
