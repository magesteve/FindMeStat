//
//  FindMeStatMapView.swift
//  FindMeStat
//
//  Created by Steve Sheets on 8/20/25.
//

// MARK: - Import

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Views

/// Custom view show map with location pin.
struct FindMeStatMapView: View {

// MARK: - Published/obervable Variables

    // The parent owns the LocationManager as a StateObject; we observe it here.
    @ObservedObject var locationManager: LocationManager

    // Camera is owned by the parent; we mutate it via binding.
    @Binding var camera: MapCameraPosition

// MARK: - Variables
    
    // Closure invoked when the user taps the flag annotation.
    var onUserFlagTapped: () -> Void

// MARK: - Structure

    /// A tiny wrapper used to drive an annotation in SwiftUI's Map
    struct UserPin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
    }

// MARK: - Computed Properties

    /// Current user Pin details
    private var userPin: UserPin? {
        if let coord = locationManager.lastLocation?.coordinate {
            return UserPin(coordinate: coord)
        }
        return nil
    }

// MARK: - Body

    var body: some View {
        Map(position: $camera) {
            if let pin = userPin {
                Annotation("You", coordinate: pin.coordinate, anchor: .bottom) {
                    VStack(spacing: 4) {
                        Image(systemName: "flag.fill")
                            .font(.title)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.red, .primary)
                            .shadow(radius: 2)
                            .onTapGesture { onUserFlagTapped() }

                        Text("You")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .ignoresSafeArea()
        .task {
            // Center once when the first location arrives.
            for await loc in firstLocationStream() {
                withAnimation(.easeInOut) {
                    camera = .region(MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                }
                break
            }
        }
    }

// MARK: - Function

    /// Await the first non-nil location from the manager.
    private func firstLocationStream() -> AsyncStream<CLLocation> {
        AsyncStream { continuation in
            let cancellable = locationManager.$lastLocation
                .compactMap { $0 }
                .sink { continuation.yield($0) }
            continuation.onTermination = { _ in cancellable.cancel() }
        }
    }
}
