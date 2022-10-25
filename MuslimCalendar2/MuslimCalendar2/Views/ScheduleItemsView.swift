//
//  ScheduleItemsView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct ScheduleItemsView: View {
    @Binding
    var scheduleItems: [ScheduleItem]
    
    var body: some View {
        List {
            ForEach($scheduleItems) { $item in
                switch item.type {
                case .prayer:
                    PrayerCardView(item: $item)
                case .event:
                    EventCardView(item: $item)
                case .availableTime:
                    AvailableTimeCardView(item: $item)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct ScheduleItemsView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleItemsView(scheduleItems: Binding.constant(ScheduleItem.sample))
    }
}
