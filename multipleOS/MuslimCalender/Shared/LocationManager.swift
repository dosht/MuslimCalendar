//
//  LocationManager.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 29.06.2022.
//

import Foundation
import CoreLocation

//TODO: apply this style instead https://stackoverflow.com/questions/57681885/how-to-get-current-location-using-swiftui-without-viewcontrollers

class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    
    func requestPermissionAndGetCurrentLocation() -> CLLocationCoordinate2D? {
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
            return nil
        }
    }
}
