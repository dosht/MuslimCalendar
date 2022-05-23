//
//  PlanView.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 22.05.2022.
//

import SwiftUI
import CoreData

struct PlanView: View {
    var body: some View {
        NavigationView {
            List {
                ForEach(PrayerName.allCases) { name in
                    NavigationLink {
                        EventsView(prayerName: name)
                    } label: {
                        Text(name.rawValue)
                    }
                    .navigationTitle("Times")
                    
                }
            }
        }
    }
}

struct EventsView: View {
    let prayerName: PrayerName
    @State var showAddEvent: Bool = false

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var events: FetchedResults<Event>
    
    init(prayerName: PrayerName) {
        self.prayerName = prayerName
        let fetchRequest = NSFetchRequest<Event>(entityName: "Event")
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \Event.timeInterval, ascending: true),
            NSSortDescriptor(keyPath: \Event.reference, ascending: true)
        ]
        fetchRequest.predicate = NSPredicate(format: "reference = %@", argumentArray: [prayerName.intValue])
        self._events = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        List {
            ForEach(events) { event in
                HStack {
                    Text(event.title ?? "Unknown")
                    Text("\(event.timeInterval/60, specifier: "%.0f")")
                    Text("\(event.duration/60, specifier: "%.0f")")
                }
            }
        }
        #if os(iOS)
        .navigationBarTitle("Events connected with \(prayerName.rawValue)", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddEvent = true }) {
                    Label("Add Event", systemImage: "plus")
                }
            }
        }
        #endif
        .sheet(isPresented: $showAddEvent) {
            AddEventView(prayerReference: prayerName, timeIntervalMinute: nextTimeInterval())
        }
    }
    
    func nextTimeInterval() -> TimeInterval {
        var nextTimeInterval: TimeInterval = 0
        if let lastEvent = events.last {
            nextTimeInterval = lastEvent.timeInterval + lastEvent.duration
        }
        return nextTimeInterval
    }
}


struct PlanView_Previews: PreviewProvider {
    static var previews: some View {
        PlanView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewInterfaceOrientation(.portraitUpsideDown)
        EventsView(prayerName: PrayerName.fajr)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
