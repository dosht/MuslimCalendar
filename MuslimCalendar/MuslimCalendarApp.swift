//
//  MuslimCalendarApp.swift
//  MuslimCalendar
//
//  Created by Mustafa Abdelhamıd on 6.03.2022.
//

import SwiftUI
import EventKit

@main
struct MuslimCalendarApp: App {
    init() {
        print("happening")
        requestPermission()
    }
    
    private let viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
    
    func requestPermission() {
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: { (success, error) in
                if success {
                    print("success")
                } else {
                    print("error while requesting permession \(String(describing: error?.localizedDescription))")
                }
            })
        case .restricted:
            print("restriced")
        case .denied:
            print("denied")
        case .authorized:
            print("authorized")
        @unknown default:
            print("unkown")
        }
    }
}
