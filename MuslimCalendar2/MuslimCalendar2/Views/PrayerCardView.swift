//
//  PrayerCardView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct PrayerCardView: View {
    @Binding
    var item: ScheduleItem
    
    var body: some View {
        Text(item.title)
    }
}

struct PrayerCardView_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var items: [ScheduleItem] = ScheduleItem.prayerSample
        
        var body: some View {
            List($items) { $item in
                PrayerCardView(item: $item)
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
