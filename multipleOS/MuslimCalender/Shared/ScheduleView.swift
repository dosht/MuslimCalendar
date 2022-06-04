//
//  CalendarView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 23.05.2022.
//

import SwiftUI
import CoreLocation

struct ScheduleView: View {
//    @ObservedObject var viewModel = RelativeEventsViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \RelativeEvent.startRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.start, ascending: true)
        ],
        animation: .default)
    var relativeEvents: FetchedResults<RelativeEvent>
    var prayerCalculator: PrayerCalculator? = PrayerCalculator(
        location: CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066), date: Date())
    
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
                        ForEach(relativeEvents) { event in
                            if event.isAllocatable {
                                AvailableTimeView(availableTime: Int(event.duration(time: prayerCalculator!.time)/60/60))
                            } else {
                                CardView(title: event.title!)
                            }
                        }
////                        DisclosureGroup("Fajr") {
//                        CardView(title: "Tahajud")
////                            Section(header: Text("Fajr")) {
//                            PrayerTimeView(prayerName: "Fajr 4:31 AM")
//                                //.font(font(from: geo.size))
//                            CardView(title: "Fajr Prayer")
//                            CardView(title: "Quran")
////                            CardView(title: "Zikr")
////                            }
////                        }
//
//                        Section(header: Text("Sunrise ☀️")) {
//
//                        CardView(title: "Sport")
//                        }
//                        AvailableTimeView(availableTime: 5)
//
//                        Section(header: Text("Duhr")) {
//                            AvailableTimeView(availableTime: 4)
//                        }
//                        Section(header: Text("Asr")){
//                            AvailableTimeView(availableTime: 3)
//                        }
//                        Section(header: Text("Maghrib")){
//                            AvailableTimeView(availableTime: 1)
//                        }
//                        Section(header: Text("Isha")){
//                            AvailableTimeView(availableTime: 1)
//                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(Text("Day Schedule"))
            .navigationViewStyle(.stack)
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
    var title: String
    
    var body: some View {
        NavigationLink(destination: EventView(title: title)) {
            HStack {
                RoundedRectangle(cornerRadius: 0, style: .continuous).fill(.yellow).frame(width: 5, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 4) {
                        Label("starts 30 min after", systemImage: "person.3").foregroundColor(.primary)
                        Spacer()
                        Label("30", systemImage: "clock")
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
    let availableTime: Int
    @State var addNew: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            Text("\(availableTime) Hours").frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            Button(action: {
                addNew = true
            }, label: {
                Label("", systemImage: "plus.circle.fill")
                    .foregroundColor(.secondary).frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                    .font(.title)
            })
        }
        .padding(30).background(.regularMaterial)
        .listRowSeparator(.hidden)
        .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
        .sheet(isPresented: $addNew) {
            EventEditor(isEditing: $addNew, isSavedEvent: false)
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
    static var previews: some View {
        Group {
            ScheduleView()
                .previewInterfaceOrientation(.portrait)
                .environment(\.managedObjectContext, viewContext)
            ScheduleView()
                .previewInterfaceOrientation(.portrait).preferredColorScheme(.dark)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
