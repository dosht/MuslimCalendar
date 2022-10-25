//
//  AvailableTimeCardView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct AvailableTimeCardView: View {
    @Binding
    var item: ScheduleItem
    
    //TODO: Localize and ploralize
    var durationText: String {
        let hour = item.duration.hour
        let minute = item.duration.minute
        var result = ""
        if let hour = hour, let minute = minute {
            result = "\(abs(hour)) hour, \(abs(minute)) minute"
        }
        else if let hour = hour {
            result = "\(abs(hour)) hour"
        }
        else if let minute = minute {
            result = "\(abs(minute)) minute"
        }
        return result
    }
    
    var body: some View {
        HStack {
            Text(durationText)
                .opacity(0.5)
            Spacer()
            Button {
            } label: {
                Label("", systemImage: "calendar.badge.plus")
            }
        }
        .padding(.vertical)
    }
}

struct AvailableTimeCardView_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var items: [ScheduleItem] = ScheduleItem.availableTimeSample
        
        var body: some View {
            List($items) { $item in
                AvailableTimeCardView(item: $item)
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
