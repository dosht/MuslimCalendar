//
//  PrayerTimes+ScheduleItem.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 25.10.2022.
//

import Foundation

extension ScheduleItem {
    static func fromPrayerCaclculation(_ prayerCalculation: PrayerCalculation) -> [ScheduleItem] {
        TimeName.allCases.enumerated()
            .map { i, timeName in
                ScheduleItem(title: timeName.rawValue, startTime: prayerCalculation.time(of: timeName), duration: 0, type: .prayer, startRelativeTo: i, endRelativeTo: i, start: 0, end: 0)
            }
    }
    static var prayerRealisticSample: [ScheduleItem] {
        ScheduleItem.fromPrayerCaclculation(PrayerCalculation.preview)
    }
    
    var startTimeName: TimeName {
        get { TimeName.allCases[Int(self.startRelativeTo)] }
        set { self.startRelativeTo = Int(newValue.intValue) }
    }
    
    var endTimeName: TimeName {
        get { TimeName.allCases[Int(self.endRelativeTo)] }
        set { self.endRelativeTo = Int(newValue.intValue) }
    }
    
    func updateTime(with prayerCalculation: PrayerCalculation) -> ScheduleItem {
        var itemWithPrayerTime = self
        let startTime = prayerCalculation.time(of: startTimeName).addingTimeInterval(start)
        let endTime = prayerCalculation.time(of: endTimeName).addingTimeInterval(end)
        itemWithPrayerTime.startTime = startTime
        itemWithPrayerTime.duration = endTime.timeIntervalSince(startTime)
        return itemWithPrayerTime
    }
}
