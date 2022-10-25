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
    @StateObject
    var prayerCalculator = PrayerCalculatorService()
    
    @StateObject
    var locationService = LocationService()
    
    @StateObject
    var scheduleViewModel = ScheduleViewModel()

    var body: some Scene {
        WindowGroup {
            ScheduleView()
                .environmentObject(scheduleViewModel)
                .onAppear {
                    locationService.$lastLocation.assign(to: &prayerCalculator.$location)
                    scheduleViewModel.$day.assign(to: &prayerCalculator.$day)
                }
                .onReceive(prayerCalculator.$prayerCalculation) { prayerCalculation in
                    scheduleViewModel.updatePrayerItems(prayerCalculation: prayerCalculation)
                }
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
