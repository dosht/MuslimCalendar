//
//  EventView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 28.05.2022.
//

import SwiftUI
import CoreLocation

struct EventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var event: RelativeEvent
    @ObservedObject var viewModel: RelativeEventsViewModel
    
    var body: some View {
        List {
            Section {
                Text("\(event.startText) \(event.startTimeName.rawValue)").padding(.top)
                Text("Duration: \(viewModel.duration(event: event).timeIntervalText)")
                Text("Repeats daily")
            }
            .listRowSeparator(.hidden)
            Section {
                HStack {
                    Text("Alert")
                    Spacer()
                    Text("10 minutes before").frame(alignment: .trailing)
                }
                HStack {
                    Text("Alarm")
                    Spacer()
                    Text("On time").frame(alignment: .trailing)
                }
            }
        }
        .sheet(isPresented: $viewModel.editingEvent) {
//            EventEditor(relativeEventsViewModel: viewModel, location: location, context: viewContext, editedEvent: event)
            EventEditor(viewModel: viewModel.editEventViewModel!, relativeEventsViewModel: viewModel)
            
        }
        .navigationTitle(event.title ?? "N/A")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.edit(event: event) }) {
                    Text( "Edit")
                }
            }
        }
    }
    
//    func createEditEventViewModel() -> EditEventViewModel {
//        EditEventViewModel(event, availableSlot: viewModel.expandAllocatableSlot(event), location: viewModel.location, context: viewContext)
//    }
}

struct EventView_Previews: PreviewProvider {
    static let location = LocationManager().requestPermissionAndGetCurrentLocation()
    static let context = PersistenceController.preview.container.viewContext
    static let viewModel = RelativeEventsViewModel(context: context, location: location, eventStore: EventStore())
    static let event = RelativeEvent.create(context, "Zikr").startAt(10*60, relativeTo: .fajr).endAt(20*60, relativeTo: .fajr)
    
    static var previews: some View {
        EventView(event: event, viewModel: viewModel)
    }
}
