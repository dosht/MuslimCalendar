//
//  EventEditor.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 29.05.2022.
//

import SwiftUI
import CoreLocation

struct EventEditor: View {
    @ObservedObject var viewModel: RelativeEventsViewModel
    @ObservedObject var event: RelativeEvent
    
//    @State var eventTitle: String = ""
    @State var duration = Duration(minutes: 30)
    @State var start = Duration()
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
                        viewModel.editingEvent = false
                    }, label: { Text("Cancel") }).padding()
                    Spacer()
                    // Done button
                    Button(action: {
                        viewModel.save()
                    }, label: { Text(viewModel.isNew ? "Add" : "Done") }).padding()
                }
            }
            Divider()
            // The form
            GeometryReader { geo in
                Form {
                    Section {
                        TextField("Event Title", text: $event.title.toUnwrapped(defaultValue: ""))
                            .padding(4)
                            .font(.title2)
                    }
                    Section {
                        
                        if event.start != 0 {
                            Picker("After/Before", selection: $event.isAfter) {
                                Text("AFter").tag(true)
                                Text("Before").tag(false)
                            }.pickerStyle(.segmented)
                        }
//                        DiscreteDurationPicker(text: "Start", duration: $)
                        
//                        DurationPicker(text: "Duration", duration: $duration, geo: geo)
                        
                        DurationPicker(text: "Start", duration: $event.start.duration, geo: geo, trailingText: " \(event.start == 0 ? "at" : event.isAfter ? "after" : "before") \(event.startTimeName)")
                        
                       
                        
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
                    viewModel.delete()
                }, label: { Text("Delete") }).padding().foregroundColor(.red)
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

struct EventEditor_Previews: PreviewProvider {
    static let viewContext = PersistenceController.preview.container.viewContext
    static let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
    static let viewModel = RelativeEventsViewModel(context: viewContext, location: location)
    
    static var previews: some View {
        EventEditor(viewModel: viewModel, event: RelativeEvent.create(viewContext, "Test title"))
            .previewInterfaceOrientation(.portrait)
    }
}

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
    
}