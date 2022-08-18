//
//  MuslimCalendarApp+Injection.swift
//  MuslimCalender (iOS)
//
//  Created by Mustafa Abdelhamıd on 15.08.2022.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { PersistenceController.shared }.scope(.application)
        register { RelativeEventRepository() }.scope(.application)
        register { EventKitRepository() }.scope(.application)
        register { LocationManager() }.scope(.application)
    }
}
