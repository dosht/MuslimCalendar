//
//  EventStore.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 19.06.2022.
//

import EventKit

struct EventStore {
    static func requestPermissionAndCreateEventStore() -> EKEventStore {
        let eventStore = EKEventStore()
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: { (success, error) in
                if success {
                    print("success")
                } else {
                    print("error while requesting permession \(String(describing: error?.localizedDescription))")
                }
            })
        case .restricted:
            print("restriced")
        case .denied:
            print("denied")
        case .authorized:
            print("authorized")
        @unknown default:
            print("unkown")
        }
        return eventStore
    }
}
