//
//  MuslimCalendar2App.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

@main
struct MuslimCalendar2App: App {
//    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ScheduleView(viewModel: ScheduleViewModel())
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
