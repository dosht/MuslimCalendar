
//  EventToolbar.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 26.08.2022.
//

import SwiftUI

struct EventToolbarView: View {
    @ObservedObject
    var viewModel: EventToolbarViewModel
    
    @State
    var showExtraOptions: EventToolbarOptions? = nil
    
    init(zip2Event: Binding<Zip2Event?>) {
        viewModel = EventToolbarViewModel(zip2Event: zip2Event)
    }
    
    var body: some View {
        HStack {
            if let showExtraOptions = showExtraOptions {
                switch showExtraOptions {
                case .position:
                    EventToolbarPositionView()
                case .time:
                    EventToolbarTimeView()
                case .calendar:
                    EventToolbarCalendarView()
                case .alarm:
                    EventToolbarAlarmView()
                }
            } else {
                HStack {
//                    Spacer()
                    Button {
                        print("position")
                        showExtraOptions.toggle(to: .position)
                    } label: {
                        Label("", systemImage: "rectangle.portrait.lefthalf.inset.filled")
                            .rotationEffect(.degrees(+90))
                    }
                    .padding(.horizontal)
                    Button {
                        print("clock")
                        showExtraOptions.toggle(to: .time)
                    } label: {
                        Label("", systemImage: "clock")
                    }
                    .padding(.horizontal)
                    Button {
                        print("calendar")
                        showExtraOptions.toggle(to: .calendar)
                    } label: {
                        Label("", systemImage: "calendar")
                    }
                    .padding(.horizontal)
                    Button {
                        print("alarm")
                        showExtraOptions.toggle(to: .alarm)
                    } label: {
                        Label("", systemImage: "alarm")
                    }
                    .padding(.horizontal)
//                    Button {
//                        print("flag")
//                    } label: {
//                        Label("", systemImage: "flag")
//                    }
//                    .padding(.horizontal)
//                    Spacer()
                }
                .padding(10)
            }
        }
        .opacity(0.7)
//        .font(.title2)
//        .background(.thinMaterial)
        .foregroundColor(.primary)
    }
}

enum EventToolbarOptions {
    case position, time, calendar, alarm
}

extension Optional<EventToolbarOptions> {
    mutating func toggle(to value: EventToolbarOptions) {
        self = (self != value) ? value : nil
    }
}

struct EventToolbarPositionView: View {
    var body: some View {
        HStack {
            Button {
                print("position")
            } label: {
                Label("", systemImage: "rectangle.portrait.lefthalf.inset.filled")
                    .rotationEffect(.degrees(+90))
            }
            .padding(.horizontal)
            Button {
                print("position")
            } label: {
                Label("", systemImage: "rectangle.portrait.righthalf.inset.filled")
                    .rotationEffect(.degrees(+90))
            }
            .padding(.horizontal)
            Button {
                print("position")
            } label: {
                Label("", systemImage: "rectangle.portrait.inset.filled")
                    .rotationEffect(.degrees(+90))
            }
            .padding(.horizontal)
        }
    }
}


struct EventToolbarTimeView: View {
    var body: some View {
        Text("EventToolbarTimeView")
    }
}

struct EventToolbarCalendarView: View {
    var body: some View {
        Text("EventToolbarCalendarView")
    }
}

struct EventToolbarAlarmView: View {
    var body: some View {
        Text("EventToolbarAlarmView")
    }
}

//struct EventToolbar_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
