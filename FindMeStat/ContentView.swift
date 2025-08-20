//
//  ContentView.swift
//  FindMeStat
//
//  Created by Steve Sheets on 8/20/25.
//
//  Content (UI) for mapping app, using MapKit.
//  LocationManager used to return geo details.
//

// MARK: - Import

import SwiftUI
import MapKit
import CoreLocation

// MARK: - Views

struct ContentView: View {

    // MARK: - Published Properties/States

    /// reference to location manager (observable)
    @StateObject private var locationManager = LocationManager.shared

    /// Track the map camera so we can center on the user once we have a fix
    @State private var camera: MapCameraPosition = .automatic

    /// Controls the sheet presentation when user taps the flag
    @State private var showDetails = false

    // MARK: - Body

    // Main Content View
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            FindMeStatMapView(
                locationManager: locationManager,
                camera: $camera,
                onUserFlagTapped: { showDetails = true }
            )
            
            VStack(spacing: 8) {
                Button {
                    if let loc = locationManager.lastLocation {
                        withAnimation(.easeInOut) {
                            camera = .region(MKCoordinateRegion(center: loc.coordinate,
                                                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                        }
                    }
                } label: {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 28, weight: .semibold))
                        .padding(10)
                        .background(.thinMaterial, in: Circle())
                }
                .accessibilityLabel("Center on my location")
            }
            .padding()
        }
        .onAppear { locationManager.request() }
        .sheet(isPresented: $showDetails) {
            if let loc = locationManager.lastLocation {
                LocationDetailsView(location: loc)
                    .presentationDetents([.medium, .large])
            } else {
                Text("Waiting for location…")
                    .padding()
                    .presentationDetents([.fraction(0.25)])
            }
        }
    }

}
