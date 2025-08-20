//
//  LocationManager.swift
//  FindMeStat
//
//  Created by Steve Sheets on 8/20/25.
//
//  Shared Location Manager.
//  Requires the apps Info.plist to have a
//  NSLocationWhenInUseUsageDescription entry give explanation of why
//  Locations are being used.
//

// MARK: - Import

import Foundation
import CoreLocation
import Combine

// MARK: - Class

/// Singleton around CLLocationManager that publishes the most recent location.
/// SwiftUI observable!
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Static Var

    /// LocationManager shared singleton
    static let shared = LocationManager()
    
    // MARK: - Private storage

    /// Internal CLLocationManager reference
    private let manager = CLLocationManager()

    // MARK: - Published Properties

    /// Last location found
    @Published var lastLocation: CLLocation?
    
    /// CUrrent authorization state
    @Published var authorization: CLAuthorizationStatus = .notDetermined
    
    /// Error message if any
    @Published var errorMessage: String?

    // MARK: - Init

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.activityType = .other
        manager.pausesLocationUpdatesAutomatically = true

        authorization = manager.authorizationStatus
    }

    // MARK: - Public API

    /// Request permission (When In Use) and begin updates if possible.
    func request() {
        guard CLLocationManager.locationServicesEnabled() else {
            errorMessage = "Location Services are disabled in Settings."
            return
        }
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            start()
        case .denied, .restricted:
            errorMessage = "Location permission is denied or restricted."
        @unknown default:
            break
        }
    }

    /// Start/stop allow views to control battery usage explicitly.
    func start() {
        guard authorization == .authorizedWhenInUse || authorization == .authorizedAlways else { return }
        manager.startUpdatingLocation()
    }

    /// Halt looking
    func stop() {
        manager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorization = manager.authorizationStatus
        switch authorization {
        case .authorizedAlways, .authorizedWhenInUse:
            start()
        case .denied, .restricted:
            stop()
            errorMessage = "Location permission is denied or restricted."
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            lastLocation = loc
            if errorMessage != nil { errorMessage = nil }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = error.localizedDescription
    }
}
