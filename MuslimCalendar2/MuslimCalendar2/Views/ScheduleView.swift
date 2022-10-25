//
//  ScheduleView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject
    var viewModel: ScheduleViewModel
  
    var body: some View {
        VStack {
            ScheduleViewTitle()
            DaysView(selectedDay: $viewModel.day)
                .onAppear {
                    viewModel.selectDay(day: .Thursday)
                }
            ScheduleItemsView(scheduleItems: $viewModel.items)
                .onReceive(viewModel.$day) { _ in
                    viewModel.loadItems()
                }
        }
    }
}

struct ScheduleViewTitle: View {
    var body: some View {
        HStack {
            Text("Day Schedule").padding(.leading, 15).font(.title)
            Spacer()
        }
    }
}

#if DEBUG
struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(ScheduleViewModel(prayerItems: ScheduleItem.prayerRealisticSample))
    }
}

extension ScheduleViewModel {
    convenience init(prayerItems: [ScheduleItem]) {
        self.init()
        self.prayerItems = prayerItems
    }
}
#endif
