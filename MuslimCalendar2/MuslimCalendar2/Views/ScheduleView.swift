//
//  ScheduleView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct ScheduleView: View {
    @State
    var scheduleItems: [ScheduleItem]
    
    var body: some View {
        VStack {
            DaysView()
            ScheduleItemsView(scheduleItems: scheduleItems)
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(scheduleItems: ScheduleItem.sample)
    }
}
