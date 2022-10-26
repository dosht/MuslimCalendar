//
//  ScheduleItemToolbarView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 25.10.2022.
//

import SwiftUI

struct ScheduleItemToolbarView: View {
    @Binding
    var item: ScheduleItem?
    
    @State
    var duration: Date = Date().startOfDay.advanced(by: 60*30)
    
    var body: some View {
        HStack {
            ScheduleRuleToggleView(item: $item, image: "rectangle.portrait.lefthalf.inset.filled", scheduleRule: .beginning)
            ScheduleRuleToggleView(item: $item, image: "rectangle.portrait.righthalf.inset.filled", scheduleRule: .end)
            ScheduleRuleToggleView(item: $item, image: "rectangle.portrait.inset.filled", scheduleRule: .full)
            if item?.scheduleRule != .full {
                DatePicker("", selection: $duration, displayedComponents: .hourAndMinute)

                    .padding(.horizontal)
            }
        }
    }
}

struct ScheduleRuleToggleView: View {
    @Binding
    var item: ScheduleItem?
    var image: String
    var scheduleRule: ScheduleItem.ScheduleRule
    
    var body: some View {
        Button {
            item?.scheduleRule = scheduleRule
        } label: {
            Label("", systemImage: image)
                .rotationEffect(.degrees(+90))
                .selected(isSelected: item?.scheduleRule == scheduleRule)
        }
        .padding(.horizontal)
    }
}

struct Selectable: ViewModifier {
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        if isSelected {
            content.foregroundColor(.blue)
        } else {
            content.foregroundColor(.black)
        }
    }
}

extension View {
    func selected(isSelected: Bool) -> some View {
        self.modifier(Selectable(isSelected: isSelected))
    }
}

#if DEBUG
struct ScheduleItemToolbarView_Previews: PreviewProvider {
    struct Preview: View {
        @State var item =
        Optional.some(
            ScheduleItem(
                title: "event",
                startTime: Date(timeString: "04:00"),
                duration: 30*60,
                type: .event,
                scheduleRule: .beginning
            )
        )
        var body: some View {
            ScheduleItemToolbarView(item: $item)
                .environment(\.locale, Locale(identifier: "en_GB"))  // Work around to use DatePicker for Duration
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
#endif
