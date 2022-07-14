//
//  CoreData+Fixtures.swift
//  Tests Shared
//
//  Created by Mustafa Abdelhamıd on 13.07.2022.
//

import Foundation
import CoreData
import MuslimCalender

extension NSManagedObjectContext {
    func all() -> [RelativeEvent] {
        let request = NSFetchRequest<RelativeEvent>(entityName: "RelativeEvent")
        var result: [RelativeEvent] = []
        try? result = self.fetch(request)
        return result
    }
}
