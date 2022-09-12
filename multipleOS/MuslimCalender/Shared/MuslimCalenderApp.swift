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
    
    @StateObject
    var relativeEventsViewModel = ScheduleViewModel()

    var body: some Scene {
        WindowGroup {
            ScheduleView()
                .environmentObject(relativeEventsViewModel)
        }
    }
}
