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
    
    var adhanTimeText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: item.startTime)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.purple).opacity(0.1)
            HStack {
                Text(item.title)
                Text(adhanTimeText)
                Spacer()
            }
            .font(.headline)
            .padding(7)
        }
        .frame(alignment: .center)
        .listRowSeparator(.hidden)
    }
}

#if DEBUG
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
#endif
