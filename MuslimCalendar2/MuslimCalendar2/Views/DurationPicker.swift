//
//  TimeIntervalPicker.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 26.10.2022.
//

import SwiftUI

struct DurationPicker: View {
    @Binding var duration: TimeInterval
    
    @Binding private var date: Date
    
    private static let gmt: TimeZone = {
        if #available(iOS 16.0, *) {
            return TimeZone.gmt
        } else {
            return TimeZone(secondsFromGMT: 0)!
        }
    }()
    
    let dateRange: ClosedRange<Date>
    
    init(duration: Binding<TimeInterval>, minHour: Int = 0, minMinute: Int = 0, maxHour: Int = 23, maxMinute: Int = 59) {
        self._duration = duration
        self._date = Binding(get: {
            let formatter = DateFormatter()
            formatter.timeZone = DurationPicker.gmt
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let initialDate = formatter.date(from: "1970-01-01T00:00:00")!
            return initialDate.advanced(by: duration.wrappedValue)
        }, set: { value in
            duration.wrappedValue = value.timeIntervalSince1970
        })
        self.dateRange = {
           let calendar = Calendar.current
            let startComponents = DateComponents(timeZone: DurationPicker.gmt, year: 1970, hour: minHour, minute: minMinute)
            let endComponents = DateComponents(timeZone: DurationPicker.gmt, year: 1970, hour: maxHour, minute: maxMinute)
           return calendar.date(from:startComponents)!
               ...
               calendar.date(from:endComponents)!
       }()
    }

    var body: some View {
        DatePicker("", selection: $date, in: dateRange, displayedComponents: .hourAndMinute)
            .environment(\.locale, Locale(identifier: "en_GB"))  // Work around to use DatePicker for Duration
            .environment(\.timeZone, DurationPicker.gmt)
            .padding(.horizontal)
    }
}

#if DEBUG
struct TimeIntervalPicker_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var duration: TimeInterval = 60*30
        
        var body: some View {
            HStack {
                DurationPicker(duration: $duration)
                Spacer()
                DurationPicker(duration: $duration)
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
#endif
