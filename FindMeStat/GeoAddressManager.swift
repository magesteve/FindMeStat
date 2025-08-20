//
//  GeoAddressManager.swift
//  FindMeStat
//
//  Created by Steve Sheets on 8/20/25.
//
//  Singleton for reverse-geocoding CLLocation into a formatted
//  address string.
//

// MARK: - Import

import Foundation
import CoreLocation
import Contacts

// MARK: - Class

/// Singleton around CLGeocoder that produces a one-line, human-readable address
/// string (or a failure description) for a given CLLocation.
final class GeoAddressManager {

    // MARK: - Singleton

    static let shared = GeoAddressManager()

    // MARK: - Private storage

    /// internal CLGeocoder
    private let geocoder = CLGeocoder()
    
    /// Stored lookup for speed
    private let cache = NSCache<NSString, NSString>()
    
    // MARK: - Init
    
    private init() {}

    // MARK: - Public API

    /// Reverse-geocode a location and return a formatted address (or failure text).
    func lookup(location: CLLocation,
                completion: @escaping (String) -> Void) {
        let key = cacheKey(for: location.coordinate)

        if let cached = cache.object(forKey: key as NSString) {
            DispatchQueue.main.async { completion(String(cached)) }
            return
        }

        if geocoder.isGeocoding {
            geocoder.cancelGeocode()
        }

        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }

            let result: String
            if let error = error as NSError? {
                result = self.geoErrorMessage(for: error)
            } else if let placemark = placemarks?.first,
                      let formatted = format(placemark: placemark) {
                result = formatted
                self.cache.setObject(formatted as NSString, forKey: key as NSString)
            } else {
                result = "Address not found."
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    /// Reverse-geocode from a coordinate convenience.
    func lookup(coordinate: CLLocationCoordinate2D,
                completion: @escaping (String) -> Void) {
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        lookup(location: loc, completion: completion)
    }

    // MARK: - Functions

    /// Async wrapper that returns a formatted address or failure text.
    public func lookup(location: CLLocation) async -> String {
        await withCheckedContinuation { cont in
            lookup(location: location) { cont.resume(returning: $0) }
        }
    }

    /// Create a readable single-line address from a CLPlacemark.
    private func format(placemark: CLPlacemark) -> String? {
        if let postal = placemark.postalAddress {
            let fmt = CNPostalAddressFormatter()
            fmt.style = .mailingAddress
            let multi = fmt.string(from: postal)
            let single = multi
                .split(whereSeparator: \.isNewline)
                .joined(separator: ", ")
                .replacingOccurrences(of: "  ", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return single.isEmpty ? nil : single
        }

        // Fallback composition from placemark parts
        var parts: [String] = []
        if let name = placemark.name, !name.isEmpty { parts.append(name) }
        if let locality = placemark.locality, !locality.isEmpty { parts.append(locality) }
        if let admin = placemark.administrativeArea, !admin.isEmpty { parts.append(admin) }
        if let postal = placemark.postalCode, !postal.isEmpty { parts.append(postal) }
        if let country = placemark.country, !country.isEmpty { parts.append(country) }

        let joined = parts.joined(separator: ", ").trimmingCharacters(in: .whitespacesAndNewlines)
        return joined.isEmpty ? nil : joined
    }

    /// Map common CLGeocoder errors to text.
    private func geoErrorMessage(for error: NSError) -> String {
        switch CLError.Code(rawValue: error.code) {
        case .network?:
            return "Address lookup failed (network error)."
        case .geocodeFoundNoResult?:
            return "No address found for this location."
        case .geocodeFoundPartialResult?:
            return "Only a partial address was found."
        case .denied?:
            return "Location access denied—cannot look up address."
        case .headingFailure?, .locationUnknown?:
            return "Location temporarily unavailable."
        default:
            return "Address lookup failed."
        }
    }

    /// Build a stable cache key by rounding to ~1 meter precision.
    private func cacheKey(for coord: CLLocationCoordinate2D) -> String {
        let lat = (coord.latitude  * 1e6).rounded() / 1e6
        let lon = (coord.longitude * 1e6).rounded() / 1e6
        return "\(lat),\(lon)"
    }
}
