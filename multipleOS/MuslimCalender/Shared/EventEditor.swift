//
//  EventEditor.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 29.05.2022.
//

import SwiftUI

struct EventEditor: View {
    @Binding var isEditing: Bool

    @State var eventTitle: String = ""
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
                Text("Edit Event").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isEditing = false
                    }, label: { Text("Done") }).padding()
                }
            }
            Divider()
            // The form
            GeometryReader { geo in
                Form {
                    Section {
                        TextField("Event Title", text: $eventTitle)
                            .padding(4)
                            .font(.title2)
                    }
                    Section {
                        
                        DurationPicker(text: "Duration", duration: $duration, geo: geo)
                        
                        DurationPicker(text: "Start", duration: $start, geo: geo, trailingText: "before fajr")
                        
                       
                        
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
        }
    }
}

struct Duration {
    var minutes: Int
    var hours: Int
    
    init(minutes: Int = 0, hours: Int = 0) {
        self.minutes = minutes
        self.hours = hours
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
                if duration.hours > 0 {
                    Text("\(duration.hours) Hours").frame(alignment: .leading)
                }
                if duration.minutes > 0 {
                    Text("\(duration.minutes) Minutes").frame(alignment: .leading)
                }
                if let trailingText = trailingText {
                    Text(trailingText)
                }
            }
        }
    }
}

struct EventEditor_Previews: PreviewProvider {
    @State static var isEditing: Bool = false
    
    static var previews: some View {
        EventEditor(isEditing: $isEditing)
    }
}
