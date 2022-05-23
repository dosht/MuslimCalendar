//
//  AddEventView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 22.05.2022.
//

import SwiftUI


struct AddEventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let prayerReference: PrayerName
    
    @State var title: String = ""
    @State var isAfter: Bool = true
    @State  var suggestedDuration: Durations = .half
    @State var timeIntervalMinute: TimeInterval
    
    var body: some View {
        Section {
            Form {
                Label("Add Event", systemImage: "bolt.fill").font(.largeTitle)
                VStack {
                    TextField("Name", text: $title)
                    Picker("Duration", selection: $suggestedDuration) {
                        ForEach(Durations.allCases) { duration in
                            Text(duration.rawValue.capitalized)
                                .tag(duration)
                        }
                    }
                    .pickerStyle(.segmented)
                    Toggle(isOn: $isAfter) {
                        Text("Before / After")
                    }
                    DisclosureGroup(/*@START_MENU_TOKEN@*/"Group"/*@END_MENU_TOKEN@*/) {
                        VStack {
                            TimeIntervalPicker(timeInterval: $timeIntervalMinute, text: "Minutes", data: Array(0..<11).map { 15 * $0 })
                        }
                    }.scaledToFill()

                    
                    
                    Divider()
//                    Button(action: addRule) {
//                        Label("Save", systemImage: "square.and.arrow.down.fill")
//                    }
                }
            }
        }
    }
    
    func addRule() {
        let event = Event(context: viewContext)
        event.reference = prayerReference.intValue
        event.title = title
        event.duration = suggestedDuration.timeInterval
        if isAfter {
            event.timeInterval = suggestedDuration.timeInterval
        } else {
            event.timeInterval = -suggestedDuration.timeInterval
        }
        try! viewContext.save()
        presentationMode.wrappedValue.dismiss()
    }
}

enum Durations: String, CaseIterable, Identifiable {
    case quarter
    case half
    case hour
    var id: Self { self }
    
    var timeInterval: TimeInterval {
        switch self {
        case .quarter: return 15*60
        case .half: return 30*60
        case .hour: return 60*60
        }
    }
}

struct TimeIntervalPicker: View {
    @Binding var timeInterval: Double
    let text: String
    let data: Array<Int>
    @State var show: Bool = true
    
    var body: some View {
        VStack {
            Text(text)
            Picker("Interval", selection: $timeInterval) {
                ForEach(data, id:\.self) { i in
                    Text(verbatim: String(i)).tag(i)
                }
            }
#if os(iOS)
            .pickerStyle(.wheel)
#endif
//            .frame(height: show ? 100 : 0)
//            .clipped()
        }
    }
}

struct AddEventView_Previews: PreviewProvider {
    @State static var timeInterval: TimeInterval = 10
    
    static var previews: some View {
//        TimeIntervalPicker(timeInterval: $timeInterval, show: true)
//            .previewInterfaceOrientation(.landscapeRight)
        AddEventView(prayerReference: .fajr, timeIntervalMinute: 30)
            .previewInterfaceOrientation(.portrait)
        
    }
}
