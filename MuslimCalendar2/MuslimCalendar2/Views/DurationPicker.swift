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
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(timeZone: gmt, year: 1970, hour: 0, minute: 1)
        let endComponents = DateComponents(timeZone: gmt, year: 1970, hour: 23, minute: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    init(duration: Binding<TimeInterval>) {
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
