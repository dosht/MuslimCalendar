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
    @EnvironmentObject var viewModel: ScheduleViewModel
    
    @State var showResetConfirmation = false
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack(spacing: 1) {
                    VStack {
                        HStack {
                            Button(action: {
                                showResetConfirmation.toggle()
                            }, label: {
                                Label("Reset", systemImage: "tornado")
                                    .foregroundColor(.red)
                            }).padding(.leading)
                            Spacer()
                            Button(action: {
                                viewModel.syncCalendar()
                            }, label: {
                                Label("Sync Calendar", systemImage: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.blue)
                            }).padding(.trailing)
                        }
                        HStack {
                            DaysView(day: "Sun", geo: geo)
                            DaysView(day: "Mon", geo: geo)
                            DaysView(day: "Tue", geo: geo, selected: true)
                            DaysView(day: "Wed", geo: geo)
                            DaysView(day: "Thu", geo: geo)
                            DaysView(day: "Fri", geo: geo)
                            DaysView(day: "Sat", geo: geo)
                        }
                    }
                    List {
                        ForEach(viewModel.relativeEvents) { event in
                            if event.isAllocatable {
                                AvailableTimeView(viewModel: viewModel, availableSlot: event)
                                    .deleteDisabled(true)
                            } else if event.isAdhan {
                                AdhanView(text: event.title!, adhanTime: viewModel.adhanTimeText(event))
                                    .deleteDisabled(true)
                            } else {
                                CardView(event: event, viewModel: viewModel, location: viewModel.location)
                            }
                        }
                        .onDelete(perform: viewModel.deleteEvent)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(Text("Day Schedule"))
            .alert("This will delete every thing. Are you sure?", isPresented: $showResetConfirmation) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteAll()
                    viewModel.deleteCalendar()
                }
            }
//            .navigationViewStyle(.stack)
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

struct AdhanView: View {
    let text: String
    let adhanTime: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.white).opacity(0.1)
            HStack {
                Text(text)
                Text(adhanTime)
                Spacer()
            }
            .font(.headline)
            .padding(7)
        }
//        .listRowSeparator(.hidden)
        .frame(alignment: .center)
    }
}

struct CardView: View {
    @ObservedObject var event: RelativeEvent
    @ObservedObject var viewModel: ScheduleViewModel
    let location: CLLocationCoordinate2D
    
    var body: some View {
        NavigationLink(destination: DetailedEventView(event: event, viewModel: viewModel)) {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.yellow).frame(width: 5, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(event.title ?? "N/A")
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 4) {
                        Label("starts \(event.startText)", systemImage: "calendar").foregroundColor(.primary)
                        Spacer()
                        Label(viewModel.duration(event: event).timeIntervalText, systemImage: "clock")
                            .labelStyle(.trailingIcon)
                            
                    }
                    .font(.caption)
                }
                .padding()
            }
        }
        .background(.thinMaterial)
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
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var viewModel: ScheduleViewModel
    var availableSlot: RelativeEvent
    
    var body: some View {
        if viewModel.duration(event: availableSlot) > 0 {
            GeometryReader { geo in
                HStack {
                    Text(viewModel.duration(event: availableSlot).timeIntervalText)
                }.frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
                    .opacity(0.5)
                Button(action: {
                    viewModel.chooseAllocatableSlot(allcatableSlot: availableSlot)
                }, label: {
                    Label("", systemImage: "calendar.badge.plus")
                        .foregroundColor(.blue).frame(width: geo.size.width, height: geo.size.height, alignment: .trailing)
                        .font(.title)
                })
            }
            .padding(30)
//            .background(.regularMaterial)
//            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
            .sheet(isPresented: $viewModel.addingNewEvent) {
                if let vm = viewModel.editEventViewModel {
                    EventEditorView(viewModel: vm, relativeEventsViewModel: viewModel)
                } else {
                    EmptyView()
                }
            }
        }
        else {
            EmptyView()
        }
    }
}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self { Self() }
}

struct CalendarView_Previews: PreviewProvider {
    static let viewContext = PersistenceController.preview.container.viewContext
    static let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
    static let viewModel = {
        let viewModel = ScheduleViewModel(context: viewContext, location: location, eventStore: EventStore())
        let event1 = RelativeEvent.create(viewContext, "Study").startAt(0, relativeTo: .fajr).endAt(30*60, relativeTo: .fajr)
        let event2 = RelativeEvent.create(viewContext, "Workout").startAt(30*60, relativeTo: .fajr).endAt(45*60, relativeTo: .fajr)
        viewModel.relativeEvents = [event1, event2]
        return viewModel
    }()
    static var previews: some View {
        Group {
            ScheduleView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(viewModel)
                .previewInterfaceOrientation(.portrait)
            ScheduleView()
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, viewContext)
                .previewInterfaceOrientation(.portrait).preferredColorScheme(.dark)
        }
    }
}

