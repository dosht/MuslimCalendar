//
//  ScheduleItemToolbarView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 25.10.2022.
//

import SwiftUI

struct ScheduleItemToolbarView: View {
    @EnvironmentObject var svm: ScheduleViewModel
    @Binding var item: ScheduleItem
    @State var expand: Bool = false
    
    var allocation: Allocation?
    
    var body: some View {
        HStack {
            Button {
                expand.toggle()
            } label: {
                Label("", systemImage: icon(of: item.scheduleRule))
                    .padding(.horizontal)
                    .rotationEffect(.degrees(+90))
            }
            if expand {
                ScheduleRuleToggleView(item: $item, isPresent: $expand, image: "rectangle.portrait.lefthalf.inset.filled", scheduleRule: .beginning)
                ScheduleRuleToggleView(item: $item, isPresent: $expand, image: "rectangle.portrait.righthalf.inset.filled", scheduleRule: .end)
                ScheduleRuleToggleView(item: $item, isPresent: $expand, image: "rectangle.portrait.inset.filled", scheduleRule: .full)
            }
            if !expand {
                HStack {
                    Picker("", selection: $item.selectedAlert) {
                        Text("No Alert").tag(AlertTime.noAlert)
                        Divider()
                        Text("Alert 0m").tag(AlertTime.atTimeOfEvent)
                        Text("Alert 5m").tag(AlertTime.before5Minutes)
                        Text("Alert 10m").tag(AlertTime.before10Minutes)
                        Text("Alert 15m").tag(AlertTime.before15Minutes)
                        Text("Alert 30m").tag(AlertTime.before30Minutes)
                        Text("Alert 1H").tag(AlertTime.before1Hour)
                        Text("Alert 2H").tag(AlertTime.before2Hours)
                    }
                }
            }
            DurationPicker(duration: $item.duration, minMinute: 1)
                .disabled(item.scheduleRule == .full)
        }
        .onChange(of: item.duration) { newValue in
            //TODO: Move to ViewModel
            if let allocation = allocation {
                item.reschedule(allocation: allocation)
                svm.refresh(item: item)
            }
        }
        .onChange(of: item.scheduleRule) { newValue in
            if let allocation = allocation {
                item.reschedule(allocation: allocation)
                svm.refresh(item: item)
            }
        }
    }
    
    private func icon(of scheduleRule: ScheduleItem.ScheduleRule) -> String {
        switch scheduleRule {
        case .beginning: return "rectangle.portrait.lefthalf.inset.filled"
        case .end: return "rectangle.portrait.righthalf.inset.filled"
        case .full: return "rectangle.portrait.inset.filled"
        }
    }
}

extension ScheduleItem {
    var selectedAlert: AlertTime {
        get { AlertTime.fromTimeInterval(self.alertOffset) }
        set { self.alertOffset = newValue.timeInterval }
    }
    
}

struct ScheduleRuleToggleView: View {
    @Binding var item: ScheduleItem
    @Binding var isPresent: Bool
    var image: String
    var scheduleRule: ScheduleItem.ScheduleRule
    
    var body: some View {
        Button {
            item.scheduleRule = scheduleRule
            isPresent.toggle()
        } label: {
            Label("", systemImage: image)
                .rotationEffect(.degrees(+90))
                .selected(isSelected: item.scheduleRule == scheduleRule)
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
        @State var item: ScheduleItem =
            ScheduleItem(
                title: "event",
                startTime: Date(timeString: "04:00"),
                duration: 30*60,
                type: .event,
                scheduleRule: .beginning
            )

        var body: some View {
            ScheduleItemToolbarView(item: $item)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
#endif
        
