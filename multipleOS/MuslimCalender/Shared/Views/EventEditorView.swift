//
//  EditEvent+View.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 10.06.2022.
//

import SwiftUI
import CoreLocation
import CoreData
import EventKit


struct EventEditorView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
//    @ObservedObject var event: RelativeEvent? = nil
    
    @ObservedObject var viewModel: EventEditorViewModel
    @ObservedObject var relativeEventsViewModel: ScheduleViewModel
  
    
    @State var alert = false
    @State var alertInterval = Duration(minutes: 10)
    @State var alarm = false
    @State var alarmInterval = Duration(minutes: 10)
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar with Done button
            ZStack {
                Text("\(viewModel.isNew ? "New" : "Edit") Event").font(.headline).padding()
                HStack {
                    Button(action: {
                        viewModel.cancel()
                        relativeEventsViewModel.cancelEditing()
                    }, label: { Text("Cancel") }).padding()
                    Spacer()
                    // Done button
                    Button(action: {
                        viewModel.save()
                        relativeEventsViewModel.doneEditing()
                    }, label: { Text(viewModel.isNew ? "Add" : "Done") }).padding()
                }
            }
            Divider()
            // The form
            GeometryReader { geo in
                Form {
                    Section {
                        TextField("Event Title", text: $viewModel.event.title.toUnwrapped(defaultValue: ""))
                            .padding(4)
                            .font(.title2)
                        Text("Between \(viewModel.event.startTimeName.rawValue) and \(viewModel.event.endTimeName.rawValue)").foregroundColor(.gray)
                    }
                    Section {
                        
                        Picker("Allocation Type", selection: $viewModel.allocationType) {
                            ForEach(EventEditorViewModel.AllocationType.allCases) { allocationType in
                                Text(allocationType.rawValue).tag(allocationType)
                            }
                        }.pickerStyle(.segmented)
//
//                        if event.start != 0 {
//                            Picker("After/Before", selection: $event.isAfter) {
//                                Text("AFter").tag(true)
//                                Text("Before").tag(false)
//                            }.pickerStyle(.segmented)
//                        }
//                        DiscreteDurationPicker(text: "Start", duration: $)
                        Text("\(viewModel.allocationType.rawValue)")
                        
                        if viewModel.showDuration {
                            DurationPicker(text: "Duration", duration: $viewModel.eventDuration.duration, geo: geo)
                        }
                    }
                    
                    Section {
                        
//                        DurationPicker(text: "Start", duration: $event.start.duration, geo: geo, trailingText: " \(event.start == 0 ? "at" : event.isAfter ? "after" : "before") \(event.startTimeName)")
                        
                       
                        
                        DisclosureGroup {
                            Text("hi")
                        } label: {
                            HStack {
                                Text("Repeat")
                                Spacer()
                                Text("Daily")
                            }
                        }
                        
                        DisclosureGroup {
                            Text("hi")
                        } label: {
                            HStack {
                                Text("End Repeat")
                                Spacer()
                                Text("Never")
                            }
                        }
                    }
                    
                    Section {
                        Toggle(isOn: $alert) {
                            Text("Add Alert")
                        }
                        if alert {
                            DurationPicker(text: "Alert Time", duration: $alertInterval, geo: geo, trailingText: "Before")
                        }
                    }
                    Section {
                        Toggle(isOn: $alarm) {
                            Text("Set Alarm")
                        }
                        if alarm {
                            DurationPicker(text: "Alarm Time", duration: $alarmInterval, geo: geo, trailingText: "Before")
                        }
                    }
                }
            }
            if !viewModel.isNew {
                Button(action: {
                    relativeEventsViewModel.deleteEvent(event: viewModel.event)
                    relativeEventsViewModel.doneEditing()
                }, label: { Text("Delete") }).padding().foregroundColor(.red)
            }
        }.onDisappear {
            viewModel.cancel()
        }
    }
}

struct DurationPicker: View {
    var text: String
    var trailingText: String?
    @Binding var duration: Duration
    var geo: GeometryProxy
    
    init(text: String, duration: Binding<Duration>, geo: GeometryProxy, trailingText: String? = nil) {
        self.text = text
        self._duration = duration
        self.geo = geo
        self.trailingText = trailingText
    }
    
    var body: some View {
        DisclosureGroup {
            HStack {
                VStack {
                    Text("Hours").padding(.top)
                    Picker("", selection: $duration.hours) {
                        ForEach(0..<12) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: geo.size.width/2 - 24, alignment: .center)
                    .clipped()
                    
                }
                .padding(-4)
                VStack {
                    Text("Minutes").padding(.top)
                    Picker("", selection: $duration.minutes) {
                        ForEach(0..<60) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: geo.size.width/2 - 24, alignment: .center)
                    .clipped()
                    
                }
                .padding(-4)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: -12, bottom: 0, trailing: 0))
        } label: {
            HStack {
                Text(text)
                Spacer()
                Text(duration.timeInterval.timeIntervalShortText)
                if let trailingText = trailingText {
                    Text(trailingText)
                }
            }
        }
    }
}

extension TimeInterval {
    var duration: Duration {
        get { Duration(timeInterval: self) }
        set { self = newValue.timeInterval }
    }
}

struct Duration {
    var minutes: Int
    var hours: Int
    
    init(minutes: Int = 0, hours: Int = 0) {
        self.minutes = minutes
        self.hours = hours
    }
    
    init(timeInterval: TimeInterval) {
        self.minutes = Int(timeInterval.minute ?? 0)
        self.hours = Int(timeInterval.hour ?? 0)
    }
    
    var timeInterval: TimeInterval {
        Double(hours * 60 * 60 + minutes * 60)
    }
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
    
}
//
//struct EventEditor_Previews: PreviewProvider {
//    static let viewContext = PersistenceController.preview.container.viewContext
//    static let relativeEventsViewModel = ScheduleViewModel()
//    static let event = RelativeEvent.create(viewContext, "Test title")
//    static let editEventViewModel = EventEditorView(event, relativeEventsViewModel: <#ScheduleViewModel#>, availableSlot: relativeEventsViewModel.expandAllocatableSlot(event), location: relativeEventsViewModel.location)
//    
//    static var previews: some View {
//        EventEditorView(viewModel: editEventViewModel, relativeEventsViewModel: relativeEventsViewModel)
//            .previewInterfaceOrientation(.portrait)
//    }
//}
