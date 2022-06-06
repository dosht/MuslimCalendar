//
//  CalendarView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 23.05.2022.
//

import SwiftUI
import CoreLocation
import CoreData
import Adhan

struct ScheduleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var prayerCalculator: PrayerCalculator? = PrayerCalculator(
        location: CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066), date: Date())
    
    @ObservedObject private var viewModel: RelativeEventsViewModel
    
    init(context: NSManagedObjectContext, location: CLLocationCoordinate2D) {
        self.viewModel = RelativeEventsViewModel(context: context, location: location)
    }
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack(spacing: 1) {
                    HStack {
                        DaysView(day: "Sun", geo: geo)
                        DaysView(day: "Mon", geo: geo)
                        DaysView(day: "Tue", geo: geo, selected: true)
                        DaysView(day: "Wed", geo: geo)
                        DaysView(day: "Thu", geo: geo)
                        DaysView(day: "Fri", geo: geo)
                        DaysView(day: "Sat", geo: geo)
                    }
                    List {
                        ForEach(TimeName.allCases) { time in
                            Section(time.rawValue) {
                                ForEach(viewModel.relativeEvents.filter{ $0.startTimeName == time }) { event in
                                    if event.isAllocatable {
                                        AvailableTimeView(viewModel: viewModel, event: event)
                                            .deleteDisabled(true)
                                    } else {
                                        CardView(event: event, viewModel: viewModel)
                                    }
                                }
                            }
                        }
                        .onDelete(perform: viewModel.deleteEvent)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(Text("Day Schedule"))
            .navigationViewStyle(.stack)
        }
        .onAppear {
            viewModel.fetch()
        }
    }
    private func font(from size: CGSize) -> Font{
        Font.system(size: min(size.height, size.width) * 0.04)
    }
}

struct DaysView: View {
    let day: String
    let geo: GeometryProxy
    var selected: Bool = false
    var body: some View {
            HStack(spacing: 1) {
                let diamiter = CGFloat(40)
                ZStack {
                    let shape = Circle()
                    if selected {
                        shape.fill(.yellow).frame(width: diamiter, height: diamiter, alignment: .leading)
                    } else {
                        shape.fill(.regularMaterial).frame(width: diamiter, height: diamiter, alignment: .leading)
                    }
//                    shape.stroke(lineWidth: CGFloat(2))
                    if selected {
                        Text(day).foregroundColor(.black)
                    } else {
                        Text(day)
                    }
                }
                
        }
    }
}

struct CardView: View {
    @ObservedObject var event: RelativeEvent
    @ObservedObject var viewModel: RelativeEventsViewModel
    
    var body: some View {
        NavigationLink(destination: EventView(event: event, viewModel: viewModel)) {
            HStack {
                RoundedRectangle(cornerRadius: 0, style: .continuous).fill(.yellow).frame(width: 5, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(event.title ?? "N/A")
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 4) {
                        Label("starts \(event.startText)", systemImage: "person.3").foregroundColor(.primary)
                        Spacer()
                        Label(viewModel.duration(event: event).timeIntervalText, systemImage: "clock")
                            .labelStyle(.trailingIcon)
                            
                    }
                    .font(.caption)
                }
                .padding()
            }
        }
//        .background(.mint)
//        .listRowInsets(.init(top: 0, leading: 15, bottom: 0, trailing: 10))
//        .listRowSeparator(.hidden)
    }
}

struct TrailingIconLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
    }
}

struct AvailableTimeView: View {
    @ObservedObject var viewModel: RelativeEventsViewModel
    var event: RelativeEvent
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                Text(viewModel.duration(event: event).timeIntervalText)
            }.frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            // Add event button
            Button(action: {
                viewModel.chooseAllocatableSlot(allcatableSlot: event)
            }, label: {
                Label("", systemImage: "plus.circle.fill")
                    .foregroundColor(.secondary).frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                    .font(.title)
            })
        }
        .padding(30).background(.regularMaterial)
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
        .sheet(isPresented: $viewModel.addingNewEvent) {
            EventEditor(viewModel: viewModel, event: viewModel.editedEvent!)
        }
    }
}

struct PrayerTimeView: View {
    let prayerName: String
    var body: some View {
//        ZStack {
            Text(prayerName)
                .listRowInsets(.init(top: 0, leading: 10, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
                .foregroundColor(.gray)
//        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self { Self() }
}



struct CalendarView_Previews: PreviewProvider {
    static let viewContext = PersistenceController.preview.container.viewContext
    static let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
    static var previews: some View {
        Group {
            ScheduleView(context: viewContext, location: location)
                .previewInterfaceOrientation(.portrait)
                .environment(\.managedObjectContext, viewContext)
            ScheduleView(context: viewContext, location: location)
                .previewInterfaceOrientation(.portrait).preferredColorScheme(.dark)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
