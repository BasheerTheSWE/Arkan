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
    private var completion: ((_ error: LocationError?) -> ())?
    
    func updateUserLocation() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.manager.delegate = self
            
            self.completion = { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
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
            completion?(.failedToGetLocation)
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        /// Updating the stored coordinates
        UserDefaults.shared.set(latitude, forKey: UDKey.latitude.rawValue)
        UserDefaults.shared.set(longitude, forKey: UDKey.longitude.rawValue)
        
        /// Getting the city and country names of the user's location and storing them in UserDefaults
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placeMarks, _ in
            if let placeMark = placeMarks?.first {
                UserDefaults.shared.set(placeMark.locality, forKey: UDKey.city.rawValue)
                UserDefaults.shared.set(placeMark.country, forKey: UDKey.country.rawValue)
                UserDefaults.shared.set(placeMark.isoCountryCode, forKey: UDKey.countryCode.rawValue)
            }
            
            self?.completion?(nil)
            self?.completion = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        completion?(.failedToGetLocation)
        completion = nil
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            self.manager.requestLocation()
        } else {
            /// Checking if the user has location services enabled
            DispatchQueue.global(qos: .userInteractive) .async { [weak self] in
                if !CLLocationManager.locationServicesEnabled() {
                    self?.completion?(.locationServicesDisabled)
                }
            }
        }
    }
}
