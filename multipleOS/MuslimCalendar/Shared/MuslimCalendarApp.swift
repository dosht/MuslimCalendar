//
//  MuslimCalendarApp.swift
//  Shared
//
//  Created by Mustafa Abdelhamıd on 21.05.2022.
//

import SwiftUI

@main
struct MuslimCalendarApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
