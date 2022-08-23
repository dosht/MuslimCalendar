//
//  AvailableTimeView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 21.08.2022.
//

import SwiftUI
import Resolver

struct NewAvailableTimeView: View {
    @EnvironmentObject var viewModel: ScheduleViewModel
    
    let zip2Event: Zip2Event
    
    var body: some View {
        if let availableTime = zip2Event.availableTime {
            HStack {
                Text("\(availableTime.timeIntervalText)")
                    .opacity(0.5)
                Spacer()
                Button {
                    viewModel.addNewEventInline(zip2Event)
                } label: {
                    Label("", systemImage: "calendar.badge.plus")
                }
            }
            .padding(.vertical)
            .deleteDisabled(true)
        }
    }
}

struct AvailableTimeView_Previews: PreviewProvider {
    static func zip2Event() -> Zip2Event {
        let repository: RelativeEventRepository = Resolver.resolve()
        let event1 = repository.newEvent().startAt(0, relativeTo: .fajr).endAt(30*60, relativeTo: .fajr)
        let event2 = repository.newEvent().startAt(0, relativeTo: .sunrise).endAt(30*60, relativeTo: .sunrise)
        return Zip2Event(index: 1, event: event1, nextEvent: event2, prayerCalculation: PrayerCalculation.preview)
    }
    
    static var previews: some View {
        Resolver.register { PersistenceController.preview }.scope(.container)
        Resolver.register { RelativeEventRepository() }.scope(.container)
        return List { NewAvailableTimeView(zip2Event: zip2Event()) }
    }
}
