
//  EventToolbar.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 26.08.2022.
//

import SwiftUI

struct EventToolbarView: View {
    @ObservedObject
    var viewModel: EventToolbarViewModel
    
    init(zip2Events: Binding<[Zip2Event]>, index: FocusState<Int?>.Binding) {
        viewModel = EventToolbarViewModel(zip2Events: zip2Events, index: index)
    }
    
    var body: some View {
        HStack {
            if let showExtraOptions = viewModel.showExtraOptions {
                switch showExtraOptions {
                case .position:
                    EventToolbarPositionView(viewModel: viewModel)
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
                        viewModel.showExtraOptions.toggle(to: .position)
                    } label: {
                        switch viewModel.position {
                        case .begnning:
                            Label("", systemImage: "rectangle.portrait.lefthalf.inset.filled")
                            .rotationEffect(.degrees(+90))
                        case .end:
                            Label("", systemImage: "rectangle.portrait.righthalf.inset.filled")
                            .rotationEffect(.degrees(+90))
                        case .full:
                            Label("", systemImage: "rectangle.portrait.inset.filled")
                            .rotationEffect(.degrees(+90))
                        }
                    }
                    .padding(.horizontal)
                    Button {
                        print("clock")
                        viewModel.showExtraOptions.toggle(to: .time)
                    } label: {
                        Label("", systemImage: "clock")
                    }
                    .padding(.horizontal)
                    Button {
                        print("calendar")
                        viewModel.showExtraOptions.toggle(to: .calendar)
                    } label: {
                        Label("", systemImage: "calendar")
                    }
                    .padding(.horizontal)
                    Button {
                        print("alarm")
                        viewModel.showExtraOptions.toggle(to: .alarm)
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
    @ObservedObject
    var viewModel: EventToolbarViewModel
    
    var body: some View {
        HStack {
            Button {
                print("position")
                viewModel.position = .begnning
            } label: {
                Label("", systemImage: "rectangle.portrait.lefthalf.inset.filled")
                    .rotationEffect(.degrees(+90))
                    .selected(isSelected: viewModel.position == .begnning)
            }
            .padding(.horizontal)
            Button {
                print("position")
                viewModel.position = .end
            } label: {
                Label("", systemImage: "rectangle.portrait.righthalf.inset.filled")
                    .rotationEffect(.degrees(+90))
                    .selected(isSelected: viewModel.position == .end)
            }
            .padding(.horizontal)
            Button {
                print("position")
                viewModel.position = .full
            } label: {
                Label("", systemImage: "rectangle.portrait.inset.filled")
                    .rotationEffect(.degrees(+90))
                    .selected(isSelected: viewModel.position == .full)
            }
            .padding(.horizontal)
            if viewModel.position != .full {
                DatePicker("", selection: $viewModel.duration, displayedComponents: .hourAndMinute)
                    .padding(.horizontal)
            }
        }
    }
}

struct Selectable: ViewModifier {
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        if isSelected {
            content.foregroundColor(.blue)
        } else {
            content
        }
    }
}

extension View {
    func selected(isSelected: Bool) -> some View {
        self.modifier(Selectable(isSelected: isSelected))
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
