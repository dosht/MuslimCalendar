//
//  LocationManager.swift
//  MuslimCalender
//
//  Created by Mustafa Abdelhamıd on 29.06.2022.
//

import Foundation
import CoreLocation
import MapKit

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let defaultLocation = CLLocation(latitude: 21.4361607, longitude: 39.9164145)

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
    }
    
    var allowsBackgroundLocationUpdates: Bool {
        set { locationManager.allowsBackgroundLocationUpdates = newValue }
        get { locationManager.allowsBackgroundLocationUpdates }
    }

    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        print(#function, statusString)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if let lastLocation = lastLocation {
            if location.distance(from: lastLocation) < 3000 { return }
        }
        lastLocation = location
    }
    
    var currentLocation: CLLocation? {
        if let lastLocation = lastLocation {
            return lastLocation
        }
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        return locationManager.location
    }
    
    // MARK: - Intents
    func start() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
