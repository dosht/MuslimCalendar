//
//  MuslimCalenderApp.swift
//  Shared
//
//  Created by Mustafa Abdelhamıd on 21.05.2022.
//

import SwiftUI

@main
struct MuslimCalenderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
//            PlanView()
            ScheduleView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
