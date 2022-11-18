//
//  MuslimCalendar2App.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

@main
struct MuslimCalendar2App: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject var prayerCalculator = PrayerCalculatorService()
    @StateObject var locationService = LocationService()
    @StateObject var placemarkService = PlacemarkService()
    @StateObject var eventKitService = EventKitService()
    @StateObject var scheduleViewModel = ScheduleViewModel()
    
    init() {
        registerUpdateCalendarBGT()
        scheduleUpdateCalendarBGT()
    }

    var body: some Scene {
        WindowGroup {
            ScheduleView()
                .environmentObject(scheduleViewModel)
                .onAppear {
                    locationService.start()
                    locationService.$lastLocation.assign(to: &prayerCalculator.$location)
                    scheduleViewModel.$day.assign(to: &prayerCalculator.$day)
                }
                .onReceive(locationService.$lastLocation) { location in
                    placemarkService.updatePlacemark(location: location)
                }
                .onReceive(prayerCalculator.$prayerCalculation) { prayerCalculation in
                    scheduleViewModel.updatePrayerItems(prayerCalculation: prayerCalculation)
                    scheduleViewModel.updateEventItems(prayerCalculation: prayerCalculation)
                }
//            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(eventKitService)
                .environmentObject(locationService)
                .environmentObject(placemarkService)
        }
    }
}
