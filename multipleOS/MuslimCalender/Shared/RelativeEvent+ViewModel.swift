//
//  RelativeEvent+ViewModel.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 3.06.2022.
//

import Foundation
import SwiftUI
import CoreData

class RelativeEventsViewModel: ObservableObject {
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \RelativeEvent.startRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.start, ascending: true)
        ],
        animation: .default)
    var relativeEvents: FetchedResults<RelativeEvent>
    
}
