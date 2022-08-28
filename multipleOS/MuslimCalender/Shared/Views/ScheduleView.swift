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
import Resolver

struct ScheduleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: ScheduleViewModel
    
    @FocusState
    var focusedIndex: Focusable<Int>?
    
//    @Published
//    var focus
    
    @State var showResetConfirmation = false
    
    var body: some View {
        GeometryReader { geo in
            NavigationView {
                VStack(spacing: 1) {
                    VStack {
                        Text("Focused: \(f())")
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
                        if let firstzip2Event = viewModel.zipEvents.first {
                            NewAvailableTimeView(zip2Event: firstzip2Event)
                        }
                        ForEach(viewModel.zipEvents.dropFirst()) { zipEvent in
                            if zipEvent.event.isAdhan {
                                AdhanView(text: zipEvent.event.title!, adhanTime: viewModel.adhanTimeText(zipEvent.event))
                            } else {
                                CardView(event: zipEvent.event, viewModel: viewModel)
                                    .focused($focusedIndex, equals: .row(value: zipEvent.index))
                                    .onSubmit { viewModel.save() }
                            }
                            NewAvailableTimeView(zip2Event: zipEvent)
                        }
                        .onDelete(perform: viewModel.deleteEvent)
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            EventToolbarView(zip2Event: $viewModel.focusedZip2Event)
                        }
                    }
                    .sync($viewModel.focusedIndex, $focusedIndex)
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
    
    private func f() -> String {
        switch focusedIndex {
        case .some(let index): return "\(index)"
        case nil: return "Nil"
        }
    }
}

struct ListItem: View {
    var body: some View {
        EmptyView()
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
        .deleteDisabled(true)
    }
}

struct CardView: View {
    @ObservedObject var event: RelativeEvent
    @ObservedObject var viewModel: ScheduleViewModel
    
    var body: some View {
        NavigationLink(destination: DetailedEventView(event: event, viewModel: viewModel)) {
            HStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous).fill(.yellow).frame(width: 5, alignment: .leading)
                VStack(alignment: .leading) {
                    TextField(event.title ?? "", text: $event.title.toUnwrapped(defaultValue: ""))
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
//
//struct AvailableTimeView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @ObservedObject var viewModel: ScheduleViewModel
//    var availableSlot: RelativeEvent
//
//    var body: some View {
//        if viewModel.duration(event: availableSlot) > 0 {
//            GeometryReader { geo in
//                HStack {
//                    Text(viewModel.duration(event: availableSlot).timeIntervalText)
//                }.frame(width: geo.size.width, height: geo.size.height, alignment: .leading)
//                    .opacity(0.5)
//                Button(action: {
//                    viewModel.chooseAllocatableSlot(allcatableSlot: availableSlot)
//                }, label: {
//                    Label("", systemImage: "calendar.badge.plus")
//                        .foregroundColor(.blue).frame(width: geo.size.width, height: geo.size.height, alignment: .trailing)
//                        .font(.title)
//                })
//            }
//            .padding(30)
////            .background(.regularMaterial)
////            .listRowSeparator(.hidden)
//            .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
//            .sheet(isPresented: $viewModel.addingNewEvent) {
//                if let vm = viewModel.editEventViewModel {
//                    EventEditorView(viewModel: vm, relativeEventsViewModel: viewModel)
//                }
//            }
//        }
//    }
//}

extension LabelStyle where Self == TrailingIconLabelStyle {
    static var trailingIcon: Self { Self() }
}

struct CalendarView_Previews: PreviewProvider {
    static func createViewModel() -> ScheduleViewModel {
        let repository: RelativeEventRepository = Resolver.resolve()
        let viewModel = ScheduleViewModel()
        let event1 = repository.newEvent().setTitle("Study").startAt(0, relativeTo: .fajr).endAt(30*60, relativeTo: .fajr)
        let event2 = repository.newEvent().setTitle("Workout").startAt(30*60, relativeTo: .fajr).endAt(45*60, relativeTo: .fajr)
        let event3 = repository.newEvent().setTitle("Study").startAt(30*60, relativeTo: .sunrise).endAt(45*60, relativeTo: .sunrise)
        viewModel.relativeEvents = [event1, event2, event3]
        viewModel.prayerCalculation = PrayerCalculation.preview
        return viewModel
    }
    static var previews: some View {
        Resolver.register { PersistenceController.preview }.scope(.container)
        Resolver.register { RelativeEventRepository() }.scope(.container)
        let viewModel = createViewModel()
        return Group {
            ScheduleView()
                .environmentObject(viewModel)
                .previewInterfaceOrientation(.portrait)
            ScheduleView()
                .environmentObject(viewModel)
                .previewInterfaceOrientation(.portrait).preferredColorScheme(.dark)
        }
    }
}

