//
//  DaysView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 24.10.2022.
//

import SwiftUI

struct DaysView: View {
    @Binding
    var selectedDay: WeekDay?
    
    let padding: CGFloat = 15
    
    var body: some View {
        HStack {
            ForEach(WeekDay.allCases) { day in
                DayView(dayName: day.rawValue.prefix(3), selected: day == selectedDay)
                    .onTapGesture {
                        selectedDay = day
                    }
            }
        }
        .padding(.leading, padding)
        .padding(.trailing, padding)
    }
}

struct DayView: View {
    var dayName: any StringProtocol
    var selected: Bool = false
    
    var body: some View {
        SelectableCircle(selected: selected)
            .overlay {
                if selected {
                    Text(dayName)
                        .foregroundColor(.black)
                } else {
                    Text(dayName)
                }
            }
    }
}

struct SelectableCircle: View {
    let selected: Bool
    
    var body: some View {
        if selected {
            Circle()
                .fill(.yellow)
        } else {
            Circle()
                .fill(.regularMaterial)
        }
    }
}

struct DaysView_Previews: PreviewProvider {
    static var previews: some View {
        DaysView(selectedDay: Binding.constant(.Monday))
    }
}
