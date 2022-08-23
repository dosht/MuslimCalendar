//
//  EventRepository.swift
//  MuslimCalender (iOS)
//
//  Created by Mustafa Abdelhamıd on 15.08.2022.
//

import Foundation
import Resolver
import CoreData

class RelativeEventRepository: ObservableObject {
    //MARK: - Dependencies
    @Injected var persistenceController: PersistenceController
    let context: NSManagedObjectContext
    
    init () {
        self.context = _persistenceController.wrappedValue.container.viewContext
    }
    
    //MARK: - Publishers
    @Published
    public var relativeEvents = [RelativeEvent]()
    
    //MARK: - API
    @discardableResult
    func fetch() -> [RelativeEvent] {
        let request = NSFetchRequest<RelativeEvent>(entityName: "RelativeEvent")
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \RelativeEvent.startRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.endRelativeTo, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.start, ascending: true),
            NSSortDescriptor(keyPath: \RelativeEvent.end, ascending: true),
        ]
        do {
            relativeEvents = try context.fetch(request)
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
        return relativeEvents
    }
    
    func deleteEvent(event: RelativeEvent) {
        context.delete(event)
        try! context.save()
        fetch()
    }
    
    
    func deleteAll() {
        relativeEvents.forEach(context.delete)
        do {
            try context.save()
        } catch let error {
            print("Error fetching: \(error.localizedDescription)")
        }
        fetch()
    }
    
    func expandAllocatableSlot(_ event: RelativeEvent) -> RelativeEvent {
        return event.expandAllocatableSlot(context: context)
    }
    
    //MARK: - Depricated API
    func save() {
        try! context.save()
    }
    
    func rollback() {
        context.rollback()
    }
    
    func newEvent() -> RelativeEvent {
        return RelativeEvent.create(context, "")
    }
}
