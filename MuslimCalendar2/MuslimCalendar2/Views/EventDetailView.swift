//
//  EventDetailView.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 11.11.2022.
//

import SwiftUI

class EventDetailViewModel: ObservableObject {
    @Published var item: ScheduleItem
    
    var selectedAlert: AlertTime {
        get { AlertTime.fromTimeInterval(item.alertOffset) }
        set { item.alertOffset = newValue.timeInterval }
    }
    
    var startPrayerPosition: PrayerPosition {
        get { PrayerPosition(prayerTime: item.startTimeName, isAfter: item.start >= 0) }
        set {
            item.startTimeName = newValue.prayerTime
            item.start = (newValue.isBefore) ? -abs(item.start) : abs(item.start)
        }
    }
    
    var endPrayerPosition: PrayerPosition {
        get { PrayerPosition(prayerTime: item.endTimeName, isAfter: item.endRelativeTo == item.startRelativeTo) }
        set {
            item.endTimeName = newValue.prayerTime
            item.end = (newValue.isBefore) ? -abs(item.end) : abs(item.end)
        }
    }
    
    var startPrayerPositionOptions: [PrayerPosition] {
        let options: [PrayerPosition] = TimeName.allCases.flatMap { timeName in
            [
                PrayerPosition(prayerTime: timeName, isAfter: false),
                PrayerPosition(prayerTime: timeName, isAfter: true)
            ]
        }
        return options.dropFirst().dropLast()
    }
    
    var endPrayerPositionOptions: [PrayerPosition] {
        if startPrayerPosition.isBefore {
            return [startPrayerPosition]
        } else {
            let nextPosition = startPrayerPositionOptions[startPrayerPositionOptions.firstIndex(of: startPrayerPosition)!+1]
            return [startPrayerPosition, nextPosition]
        }
    }
    
    init(item: ScheduleItem) {
        self.item = item
    }
}

struct EventDetailView: View {
    @ObservedObject var vm: EventDetailViewModel
    
    init(item: ScheduleItem) {
        self.vm = EventDetailViewModel(item: item)
    }

    var body: some View {
        Form {
            Section {
                TextField("Event Name", text: $vm.item.title).font(.title)
            }
            Section {
                HStack {
                    VStack {
                        HStack {
                            Text("Starts")
                            DurationPicker(duration: $vm.item.start, minMinute: 0)
                        }
                        Picker("", selection: $vm.startPrayerPosition) {
                            ForEach(vm.startPrayerPositionOptions) { position in
                                position.text
                            }
                        }.pickerStyle(.menu)
                    }
                }
                HStack {
                    VStack {
                        HStack {
                            Text("Ends")
                            DurationPicker(duration: $vm.item.end, minMinute: 0)
                        }
                        Picker("", selection: $vm.endPrayerPosition) {
                            ForEach(vm.endPrayerPositionOptions) { position in
                                position.text
                            }
                        }.pickerStyle(.menu)
                    }
                }
            }
            Section {
                HStack {
                    Picker("Alert", selection: $vm.selectedAlert) {
                        Text("No Alert").tag(AlertTime.noAlert)
                        Divider()
                        Text("5 minutes before").tag(AlertTime.before5Minutes)
                        Text("10 minutes before").tag(AlertTime.before10Minutes)
                        Text("15 minutes before").tag(AlertTime.before15Minutes)
                        Text("30 minutes before").tag(AlertTime.before30Minutes)
                        Text("1 hour before").tag(AlertTime.before1Hour)
                        Text("2 hours before").tag(AlertTime.before2Hours)
                    }
                }
            }
        }
//            .interactiveDismissDisabled()
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(item: ScheduleItem.eventSample[0])
    }
}

struct PrayerPosition {
    let prayerTime: TimeName
    let isAfter: Bool
    var isBefore: Bool { !isAfter }
}

extension PrayerPosition: Hashable, Identifiable {
    var id: Self { self }
    var text: some View {
        Text("\(isAfter ? "after" : "before") \(prayerTime.rawValue)").tag(self)
    }
}

enum AlertTime: String, CaseIterable, Identifiable {
    case noAlert, atTimeOfEvent, before5Minutes, before10Minutes, before15Minutes, before30Minutes, before1Hour, before2Hours
    var id: Self { self }
}

extension AlertTime {
    var timeInterval: TimeInterval? {
        switch self {
        case .noAlert: return nil
        case .atTimeOfEvent: return 0
        case .before5Minutes: return -5*60
        case .before10Minutes: return -10*60
        case .before15Minutes: return -15*60
        case .before30Minutes: return -30*60
        case .before1Hour: return -60*60
        case .before2Hours: return -2*60*60
        }
    }
    
    static func fromTimeInterval(_ timeInterval: TimeInterval?) -> AlertTime {
        switch timeInterval {
        case .none: return .noAlert
        case .some(-0): return .atTimeOfEvent
        case .some(-5*60): return .before5Minutes
        case .some(-10*60): return .before10Minutes
        case .some(-15*60): return .before15Minutes
        case .some(-30*60): return .before30Minutes
        case .some(-60*60): return .before1Hour
        case .some(-2*60*60): return .before2Hours
        default: return .noAlert
        }
    }
    
    var shortText: String {
        switch self {
        case .noAlert: return "No alert"
        case .atTimeOfEvent: return "0m"
        case .before5Minutes: return"5m"
        case .before10Minutes: return"10m"
        case .before15Minutes: return "15m"
        case .before30Minutes: return "30m"
        case .before1Hour: return "1h"
        case .before2Hours: return"2H"
        }
    }
}
