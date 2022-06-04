//
//  EventView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 28.05.2022.
//

import SwiftUI
import CoreLocation

struct EventView: View {
    var event: RelativeEvent
    @ObservedObject var viewModel: RelativeEventsViewModel
    
    @State private var isEditing: Bool = false
    
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
        .sheet(isPresented: $isEditing) {
            EventEditor(isEditing: $isEditing, isSavedEvent: true)
            
            
        }
        .navigationTitle(event.title!)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isEditing.toggle() }) {
                    Text( "Edit")
                }
            }
        }
    }
}

struct EventView_Previews: PreviewProvider {
    static let location = CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
    static let context = PersistenceController.preview.container.viewContext
    static let viewModel = RelativeEventsViewModel(context: context, location: location)
    static let event = RelativeEvent.create(context, "Zikr").startAt(10*60, relativeTo: .fajr).endAt(20*60, relativeTo: .fajr)
    
    static var previews: some View {
        EventView(event: event, viewModel: viewModel)
    }
}
