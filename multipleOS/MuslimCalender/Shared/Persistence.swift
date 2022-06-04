//
//  Persistence.swift
//  Shared
//
//  Created by Mustafa Abdelhamıd on 21.05.2022.
//

import CoreData

struct PersistenceController {
    static let shared: PersistenceController = {
        let result = PersistenceController()
        initEvents(result.container.viewContext)
        return result
    }()

    static func initEvents(_ context: NSManagedObjectContext) {
        if context.isEmpty(of: "RelativeEvent") {
            RelativeEvent.create(context).isAllocatable(true).startAt(0, relativeTo: .midnight).endAt(0, relativeTo: .fajr)
            RelativeEvent.create(context).isAllocatable(true).startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
            RelativeEvent.create(context, "before fajr").startAt(-30*60, relativeTo: .fajr).endAt(0, relativeTo: .fajr)
//            RelativeEvent.create(context, "after fajr").startAt(0, relativeTo: .fajr).endAt(30*60, relativeTo: .fajr)
//            RelativeEvent.create(context, "between fajr and sunrise").startAt(0, relativeTo: .fajr).endAt(0, relativeTo: .sunrise)
//            RelativeEvent.create(context, "between fajr and after sunrise").startAt(0, relativeTo: .fajr).endAt(30*60, relativeTo: .sunrise)
            RelativeEvent.create(context).isAllocatable(true).startAt(0, relativeTo: .sunrise).endAt(0, relativeTo: .dhur)
            RelativeEvent.create(context).isAllocatable(true).startAt(0, relativeTo: .dhur).endAt(0, relativeTo: .asr)
            RelativeEvent.create(context).isAllocatable(true).startAt(0, relativeTo: .asr).endAt(0, relativeTo: .maghrib)
            RelativeEvent.create(context).isAllocatable(true).startAt(0, relativeTo: .maghrib).endAt(0, relativeTo: .isha)
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
  
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        initEvents(result.container.viewContext)
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MuslimCalender")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension NSManagedObjectContext {
    func isEmpty(of entityName: String) -> Bool {
        if let count = try? self.count(for: NSFetchRequest(entityName: entityName)) {
            if count == 0 {
                return true
            }
        }
        return false
    }
}
