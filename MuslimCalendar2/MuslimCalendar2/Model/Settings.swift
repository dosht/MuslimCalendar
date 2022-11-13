//
//  City.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 13.11.2022.
//

import Foundation
import Adhan

struct Settings {
    var calculationMethod: CalculationMethod = .other
    var defaultCalendar: String? = "Muslim Calendar"
    var defaultAlertMinutes: Int?
    
}

struct City {
    let name: String
    let lat: Float
    let long: Float
}

#if DEBUG
extension City {
    var testCity: City {
        City(name: "Gölcük", lat: 0, long: 0)
    }
}
#endif
