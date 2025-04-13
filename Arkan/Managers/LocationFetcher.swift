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
    
    func updateUserLocation() async throws -> (latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        return try await withCheckedThrowingContinuation { continuation in
            self.manager.delegate = self
            
            self.completion = { error, latitude, longitude in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: (latitude, longitude))
                }
            }
            
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
                
            case .restricted:
                continuation.resume(throwing: LocationError.locationPermissionIsRestricted)
                
            case .denied:
                continuation.resume(throwing: LocationError.locationPermissionDenied)
                
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
                
            @unknown default:
                continuation.resume(throwing: LocationError.failedToGetLocation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placeMarks, _ in
            if let placeMark = placeMarks?.first {
                UserDefaults.standard.set(placeMark.locality, forKey: UDKey.city.rawValue)
                UserDefaults.standard.set(placeMark.country, forKey: UDKey.country.rawValue)
                UserDefaults.standard.set(placeMark.isoCountryCode, forKey: UDKey.countryCode.rawValue)
            }
            
            self?.completion?(nil, latitude, longitude)
        }
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
