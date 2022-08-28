//
//  EventToolbarViewModel.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 28.08.2022.
//

import SwiftUI

class EventToolbarViewModel: ObservableObject {
    @Binding
    var zip2Event: Zip2Event?
    
    init(zip2Event: Binding<Zip2Event?>) {
        self._zip2Event = zip2Event
    }
}
