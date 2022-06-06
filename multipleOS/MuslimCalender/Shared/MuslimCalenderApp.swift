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
//    let persistenceController = PersistenceController.shared
    let persistenceController = PersistenceController.preview
    let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)

    var body: some Scene {
        WindowGroup {
            ScheduleView(context: persistenceController.container.viewContext, location: location)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
