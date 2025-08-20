//
//  CLLocation+details.swift
//  FindMeStat
//
//  Created by Steve Sheets on 8/20/25.
//
//  Extension for to provide formatted details
//

// MARK: - Import

import CoreLocation

// MARK: - Globals

private var gDetailDateFormatter: DateFormatter {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .medium
    return df
}

// MARK: - Extension

// Detail extensions
extension CLLocation {
    
    /// Formatted latitude detail
    public var latitudeString: String {
        String(format: "%.6f", self.coordinate.latitude)
    }

    /// Formatted longitude detail
    public var longitudeString: String {
        String(format: "%.6f", self.coordinate.longitude)
    }
    
    /// Formatted altitude detail
    public var altitudeString: String {
        if self.verticalAccuracy >= 0 {
            return String(format: "%.1f m", self.altitude)
        } else {
            return "—"
        }
    }
    
    /// Formatted vertial accuracy detail
    public var verticalAccuracyString: String {
        self.horizontalAccuracy >= 0 ? String(format: "±%.1f m", self.horizontalAccuracy) : "—"
    }
    
    /// Formatted horizontal accuracy detail
    public var horizontalAccuracyString: String {
        self.horizontalAccuracy >= 0 ? String(format: "±%.1f m", self.horizontalAccuracy) : "—"
    }
    
    /// Formatted timestamp detail
    public var timestampString: String {
        return gDetailDateFormatter.string(from: self.timestamp)
    }
    
    /// Formatted speed detail
    public var speedString: String {
        if self.speed >= 0 {
            // meters/second to km/h
            let kph = self.speed * 3.6
            return String(format: "%.1f km/h", kph)
        } else {
            return "—"
        }
    }
    
    /// Formatted course detail
    public var courseString: String {
        self.course >= 0 ? String(format: "%.0f°", self.course) : "—"
    }
    
}
