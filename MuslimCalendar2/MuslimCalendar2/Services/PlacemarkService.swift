//
//  PlaceMarkService.swift
//  MuslimCalendar2
//
//  Created by Mustafa Abdelhamıd on 18.11.2022.
//

import Foundation
import CoreLocation

class PlacemarkService: ObservableObject {
    // MARK: - Publisher(s)
    @Published var placemark: CLPlacemark?
    
    // MARK: - Intent(s)
    func updatePlacemark(location: CLLocation?) {
        guard let location = location else { return }
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, errors in
            guard let self = self else { return }
            self.placemark = placemarks?.first
        }
    }
}
