    //
//  MuslimCalenderApp.swift
//  Shared
//
//  Created by Mustafa Abdelhamıd on 21.05.2022.
//

import SwiftUI
import CoreLocation

@main
struct MuslimCalenderApp: App {
    private let relativeEventsViewModel = RelativeEventsViewModel(
        context: PersistenceController.shared.container.viewContext,
//        context: PersistenceController.preview.container.viewContext,
        location: LocationManager().requestPermissionAndGetCurrentLocation(),
        eventStore: EventStore()
    )

    var body: some Scene {
        WindowGroup {
            ScheduleView(viewModel: relativeEventsViewModel)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
//                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
