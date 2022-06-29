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
//        context: PersistenceController.shared.container.viewContext,
        context: PersistenceController.preview.container.viewContext,
        location: CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066),
        ekEventStore: EventStore.requestPermissionAndCreateEventStore()
    )

    var body: some Scene {
        WindowGroup {
            ScheduleView(viewModel: relativeEventsViewModel)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
