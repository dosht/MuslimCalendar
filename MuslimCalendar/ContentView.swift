//
//  ContentView.swift
//  MuslimCalendar
//
//  Created by Mustafa Abdelhamıd on 6.03.2022.
//

import SwiftUI
import Adhan
import KVKCalendar
import EventKit


struct ContentView: View {
    @State var events: [Event] = Test.test()
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                CalendarDisplayView(geo: geo, events: $events)
            }
            AddEventViiew()
        }
    }
}

enum Durations: String, CaseIterable, Identifiable {
    case quarter
    case half
    case hour
    var id: Self { self }
}

struct AddEventViiew: View {
    @State var eventTitle: String = ""
    @State var isAfter: Bool = true
    @State  var suggestedDuration: Durations = .half
    
    var body: some View {
        Section {
            Form {
                Label("Add Event", systemImage: "bolt.fill").font(.largeTitle)
                VStack {
                    TextField("Title", text: $eventTitle)
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
                    Divider()
                    HStack {
                        Button(action: cancel) {
                            Label("Cancel", systemImage: "square.and.arrow.down.fill")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        Spacer()
                        Button(action: save) {
                            Label("Save", systemImage: "clear")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    func save() { }
    func cancel() { }
}

struct CalendarDisplayView: UIViewRepresentable {
    @Binding var events: [Event]
    private var geo: GeometryProxy
    private var calendar: CalendarView
        
    func makeUIView(context: UIViewRepresentableContext<CalendarDisplayView>) -> CalendarView {
        calendar.dataSource = context.coordinator
        calendar.delegate = context.coordinator
        calendar.reloadData()
        return calendar
    }
    
    func updateUIView(_ uiView: CalendarView, context: UIViewRepresentableContext<CalendarDisplayView>) {
        context.coordinator.events = events
    }
    
    func makeCoordinator() -> CalendarDisplayView.Coordinator {
        Coordinator(self)
    }
    
    public init(geo: GeometryProxy, events: Binding<[Event]>) {
        self._events = events
        self.geo = geo
        self.calendar = {
            let style = Style()
            let frame: CGRect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: geo.size.width, height: geo.size.height))
            return CalendarView(frame: frame, style: style)
        }()
    }
    
    // MARK: Calendar DataSource and Delegate
    class Coordinator: NSObject, CalendarDataSource, CalendarDelegate {
        private let view: CalendarDisplayView
        
        var events: [Event] = [] {
            didSet {
                view.calendar.reloadData()
            }
        }
        
        init(_ view: CalendarDisplayView) {
            self.view = view
            super.init()
        }
        
        func eventsForCalendar(systemEvents: [EKEvent]) -> [Event] {
            return events
        }
    }
}

//public struct Style {
//    public var event = EventStyle()
//    public var timeline = TimelineStyle()
//    public var week = WeekStyle()
//    public var allDay = AllDayStyle()
//    public var headerScroll = HeaderScrollStyle()
//    public var month = MonthStyle()
//    public var year = YearStyle()
//    public var list = ListViewStyle()
//    public var locale = Locale.current
//    public var calendar = Calendar.current
//    public var timezone = TimeZone.current
//    public var defaultType: CalendarType?
//    public var timeHourSystem: TimeHourSystem = .twentyFourHour
//    public var startWeekDay: StartDayType = .monday
//    public var followInSystemTheme: Bool = false
//    public var systemCalendars: Set<String> = []
//}

struct Test {
    static func test() -> [Event] {
        var prayerEvents: [PrayerEvent] = []
        
        let cal = Calendar(identifier: Calendar.Identifier.gregorian)
        let date = cal.dateComponents([.year, .month, .day], from: Date())
        // 40,71910° N, 29,78066° E
        let coordinates = Coordinates(latitude: 40.71910, longitude: 29.78066)
        var params = CalculationMethod.turkey.params
        params.madhab = .shafi
        params.method = .turkey
        if let prayers = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params) {
            var localTimeZoneIdentifier: String { return TimeZone.current.identifier }
            print(localTimeZoneIdentifier)
            let formatter = DateFormatter()
            formatter.timeStyle = .medium
            formatter.timeZone = TimeZone(identifier: localTimeZoneIdentifier)!

            print("fajr \(formatter.string(from: prayers.fajr))")
            print("sunrise \(formatter.string(from: prayers.sunrise))")
            print("dhuhr \(formatter.string(from: prayers.dhuhr))")
            print("asr \(formatter.string(from: prayers.asr))")
            print("maghrib \(formatter.string(from: prayers.maghrib))")
            print("isha \(formatter.string(from: prayers.isha))")
            
            prayerEvents.append(PrayerEvent(name: "Fajr", duration: 60*30, startDate: prayers.fajr))
            prayerEvents.append(PrayerEvent(name: "Sunrise ☀️", duration: 60*30, startDate: prayers.sunrise))
            prayerEvents.append(PrayerEvent(name: "Dhur", duration: 60*30, startDate: prayers.dhuhr))
            prayerEvents.append(PrayerEvent(name: "Asr", duration: 60*30, startDate: prayers.asr))
            prayerEvents.append(PrayerEvent(name: "Maghrib ", duration: 60*30, startDate: prayers.maghrib))
            prayerEvents.append(PrayerEvent(name: "Isha", duration: 60*30, startDate: prayers.isha))
        }
        
        return prayerEvents.map { p in p.event }
    }
}

//TODO: Change this into a protocol
struct PrayerEvent {
    let name: String
    let duration: TimeInterval
    let startDate: Date
    var endDate: Date {
        get { Date(timeInterval: duration, since: startDate) }
    }
    
    var event: Event {
        var event = Event(ID: name)
        event.text = name
        event.start = startDate
        event.end = endDate
        event.isAllDay = false
        event.isContainsFile = false
        event.recurringType = .none
        return event
    }
    
    func eventAfter(_ name: String, for duration: TimeInterval) -> PrayerEvent {
        let event = PrayerEvent(name: name, duration: duration, startDate: startDate)
        return event
    }
    
    func eventBefore(_ name: String, for duration: TimeInterval) -> PrayerEvent {
        let event = PrayerEvent(name: name, duration: duration, startDate: startDate)
        return event
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
