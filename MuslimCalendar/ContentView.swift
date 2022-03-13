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
    @State var events: [Event] = []
    
    var body: some View {
        HStack {
            GeometryReader { geo in
                CalendarDisplayView(geo: geo, events: $events)
            }
        }
        
//        VStack {
//            ScrollView {
//                LazyVGrid(columns: [GridItem(.flexible())]) {
//                    ForEach(1..<24, content: {i in
//                        HourView(hour: i)
//                    })
//                }
//            }
//        }
    }
}

struct HourView: View {
    let hour: Int
    var body: some View {
        HStack {
//            let shape = RoundedRectangle(cornerRadius: 0)
            let shape = Rectangle()
            Text("\(hour)").padding(.bottom).padding(.bottom).padding(.leading)
            VStack {
                shape
                    .padding(.trailing)
                shape
                    .stroke(lineWidth: 1)
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
        }
    }
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
    static func test() -> String {
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
        }
        return "OK"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
