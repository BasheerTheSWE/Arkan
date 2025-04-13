//
//  LocationFetcher.swift
//  Arkan
//
//  Created by Basheer Abdulmalik on 13/04/2025.
//

import Foundation
import CoreLocation

@Observable class LocationFetcher: NSObject, CLLocationManagerDelegate {
    
    enum LocationError: Error {
        case locationServicesDisabled
        case locationPermissionIsRestricted
        case locationPermissionDenied
        case failedToGetLocation
    }
    
    private let manager = CLLocationManager()
    private var completion: ((_ error: LocationError?, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> ())?
    
    func updateUserLocation(completion: ((_ error: LocationError?, _ latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) -> ())?) {
        self.manager.delegate = self
        self.completion = completion
        
        /// Now we'll check the location authorization status
        switch manager.authorizationStatus {
        case .notDetermined:
            /// This is the user's first time open and we haven't asked for location yet
            manager.requestWhenInUseAuthorization()
            break
        
        case .restricted:
            completion?(.locationPermissionIsRestricted, 0, 0)
            return
            
        case .denied:
            completion?(.locationPermissionDenied, 0, 0)
            return
            
        case .authorizedAlways, .authorizedWhenInUse:
            /// Everything is working well
            manager.requestLocation()
            break
            
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Fuch yea")
        guard let location = locations.first else {
            completion?(.failedToGetLocation, 0, 0)
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        /// Updating the stored coordinates
        UserDefaults.standard.set(latitude, forKey: UDKey.latitude.rawValue)
        UserDefaults.standard.set(longitude, forKey: UDKey.longitude.rawValue)
        
        /// Getting the city and country names of the user's location and storing them in UserDefaults
        CLGeocoder().reverseGeocodeLocation(location) { placeMarks, error in
            guard error == nil else { return }
            
            if let placeMark = placeMarks?.first {
                UserDefaults.standard.set(placeMark.locality, forKey: UDKey.city.rawValue)
                UserDefaults.standard.set(placeMark.country, forKey: UDKey.country.rawValue)
                UserDefaults.standard.set(placeMark.isoCountryCode, forKey: UDKey.countryCode.rawValue)                
            }
        }
        
        completion?(nil, latitude, longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        completion?(.failedToGetLocation, 0, 0)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            self.manager.requestLocation()
        } else {
            /// Checking if the user has location services enabled
            DispatchQueue.global(qos: .userInteractive) .async { [weak self] in
                if !CLLocationManager.locationServicesEnabled() {
                    self?.completion?(.locationServicesDisabled, 0, 0)
                }
            }
        }
    }
}
