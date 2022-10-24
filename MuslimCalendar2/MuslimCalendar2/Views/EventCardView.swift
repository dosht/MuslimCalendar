//
//  EventCardView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct EventCardView: View {
    @Binding
    var item: ScheduleItem
    
    var body: some View {
        Text(item.title)
    }
}

struct EventCardView_Previews: PreviewProvider {
    struct Preview: View {
        @State
        var items: [ScheduleItem] = ScheduleItem.eventSample
        
        var body: some View {
            List($items) { $item in
                EventCardView(item: $item)
            }
        }
    }
    static var previews: some View {
        Preview()
    }
}
