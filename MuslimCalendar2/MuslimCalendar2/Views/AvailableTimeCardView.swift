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
    
    var body: some View {
        HStack {
            Text("1h 50m")
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
