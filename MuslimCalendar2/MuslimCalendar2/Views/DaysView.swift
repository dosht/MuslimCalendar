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
    let geo: GeometryProxy
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
        .frame(height: CGFloat(geo.size.width/7))
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

#if DEBUG
struct DaysView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            VStack {
                DaysView(selectedDay: Binding.constant(.Monday), geo: geo)
                    .background(.gray)
                Text("HI")
            }
        }
    }
}
#endif
