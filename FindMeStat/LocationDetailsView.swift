//
//  LocationDetailsView.swift
//  FindMeStat
//
//  Created by Steve Sheets on 8/20/25.
//

// MARK: - Import

import SwiftUI
import CoreLocation

// MARK: - Class

/// Bottom Sheet with Location Info (live-updated address via GeoAddressManager)
struct LocationDetailsView: View {
    
    // MARK: - Variables
    
    /// Current location
    let location: CLLocation

    // MARK: - Published Properties
    
    /// Location Detail Model
    @StateObject private var model = LocationDetailsModel()

    // MARK: - Body
    
    // Body of view
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Capsule()
                    .frame(width: 36, height: 5)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("Your Location")
                    .font(.title3).bold()

                Group {
                    Text("Latitude: \(location.latitudeString)")
                    Text("Longitude: \(location.longitudeString)")
                    Text("Altitude: \(location.altitudeString)")
                    Text("Horizontal Accuracy: \(location.horizontalAccuracyString)")
                    Text("Vertical Accuracy: \(location.verticalAccuracyString)")
                    Text("Speed: \(location.speedString)")
                    Text("Course: \(location.courseString)")
                    Text("Timestamp: \(location.timestampString)")
                    Text("Address: \(model.addressDetails ?? (model.isLookingUp ? "Looking up…" : "—"))")
                }
                .font(.body.monospacedDigit())

                Spacer(minLength: 20)
            }
            .padding()
        }
        .task(id: location.timestamp) {
            model.isLookingUp = true
            GeoAddressManager.shared.lookup(location: location) { text in
                model.addressDetails = text
                model.isLookingUp = false
            }
        }
    }
}
