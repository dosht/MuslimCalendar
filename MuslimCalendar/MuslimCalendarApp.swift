//
//  MuslimCalendarApp.swift
//  MuslimCalendar
//
//  Created by Mustafa Abdelhamıd on 6.03.2022.
//

import SwiftUI

@main
struct MuslimCalendarApp: App {
    private let viewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
