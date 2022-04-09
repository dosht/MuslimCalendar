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
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                CalendarDisplayView(geo: geo, viewModel: viewModel)
            }
            if viewModel.willAddEvent {
                AddEventViiew(viewModel: viewModel)
            }
        }
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

struct AddEventViiew: View {
    @ObservedObject var viewModel: ViewModel
    
    var chosenEventTitle:  String?  {
        viewModel.chosenEvent?.text
    }
    @State var eventTitle: String = ""
    @State var isAfter: Bool = true
    @State  var suggestedDuration: Durations = .half
    
    var body: some View {
        Section {
            Form {
                Label("Add Event", systemImage: "bolt.fill").font(.largeTitle)
                if let chosenEventTitle = chosenEventTitle {
                    Label("Connected with \(chosenEventTitle)", systemImage: "highlighter")
                }
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
                            Label("Cancel", systemImage: "clear")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        Spacer()
                        Button(action: save) {
                            Label("Save", systemImage: "square.and.arrow.down.fill")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
    }
    func save() {
        viewModel.addEvent(eventTitle, suggestedDuration.timeInterval, after: isAfter)
        viewModel.chosenEvent = nil
    }
    func cancel() { viewModel.chosenEvent = nil }
}

struct CalendarDisplayView: UIViewRepresentable {
    @ObservedObject var viewModel: ViewModel
    private var geo: GeometryProxy
    private var calendar: CalendarView
        
    func makeUIView(context: UIViewRepresentableContext<CalendarDisplayView>) -> CalendarView {
        calendar.dataSource = context.coordinator
        calendar.delegate = context.coordinator
        calendar.reloadData()
        return calendar
    }
    
    func updateUIView(_ uiView: CalendarView, context: UIViewRepresentableContext<CalendarDisplayView>) {
        context.coordinator.events = viewModel.events
    }
    
    func makeCoordinator() -> CalendarDisplayView.Coordinator {
        Coordinator(self, viewModel: viewModel)
    }
    
    public init(geo: GeometryProxy, viewModel: ViewModel) {
        self.viewModel  = viewModel
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
        private let viewModel: ViewModel
        
        var events: [Event] = [] {
            didSet {
                view.calendar.reloadData()
            }
        }
        
        init(_ view: CalendarDisplayView, viewModel: ViewModel) {
            self.view = view
            self.viewModel = viewModel
            super.init()
        }
        
        func eventsForCalendar(systemEvents: [EKEvent]) -> [Event] {
            return events
        }
        
        func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {
            print("clicked: \(event)")
            viewModel.chooseEvent(event)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    private static let viewModel = ViewModel()
    
    static var previews: some View {
        ContentView(viewModel: viewModel)
            .previewInterfaceOrientation(.portrait)
    }
}
