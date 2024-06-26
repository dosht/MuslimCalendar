//
//  EventView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 28.05.2022.
//

import SwiftUI
import CoreLocation

struct DetailedEventView: View {
    @ObservedObject var event: RelativeEvent
    @ObservedObject var viewModel: ScheduleViewModel
    
    var body: some View {
        VStack {
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
            Button(action: {
                viewModel.deleteEvent(event: event)
                viewModel.doneEditing()
            }, label: { Text("Delete") }).padding().foregroundColor(.red)
        }
        .sheet(isPresented: $viewModel.editingEvent) {
//            EventEditor(relativeEventsViewModel: viewModel, location: location, context: viewContext, editedEvent: event)
            EventEditorView(viewModel: viewModel.editEventViewModel!, relativeEventsViewModel: viewModel)
            
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
    static let context = PersistenceController.preview.container.viewContext
    static let viewModel = ScheduleViewModel()
    static let event = RelativeEvent.create(context, "Zikr").startAt(10*60, relativeTo: .fajr).endAt(20*60, relativeTo: .fajr)
    
    static var previews: some View {
        DetailedEventView(event: event, viewModel: viewModel)
    }
}
