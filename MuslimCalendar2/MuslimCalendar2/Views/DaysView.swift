//
//  DaysView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct DaysView: View {
    @Binding
    var selectedDay: WeekDay
    
    var body: some View {
        Text(selectedDay.rawValue)
    }
}

struct DaysView_Previews: PreviewProvider {
    static var previews: some View {
        DaysView(selectedDay: Binding.constant(.Monday))
    }
}
