//
//  LocationManager.swift
//  MuslimCalendar
//
//  Created by Mustafa Abdelhamıd on 13.05.2022.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    func requestPermissionAndGetCurrentLocation() -> CLLocationCoordinate2D {
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            print("location service is enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        if let location = locationManager.location {
            print("found location \(location.coordinate)")
            return location.coordinate
        } else {
            print("Couldn't get location")
            return CLLocationCoordinate2D(latitude: 40.71910, longitude: 29.78066)
        }
    }
}
