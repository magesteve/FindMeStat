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
    
    /// Controls the sheet presentation when user taps the about icon
    @State private var showAbout = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            FindMeStatMapView(
                locationManager: locationManager,
                camera: $camera,
                onUserFlagTapped: { showDetails = true }
            )
            
            VStack(spacing: 8) {
                // Center on location button
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

                // About button
                Button {
                    showAbout = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 24, weight: .regular))
                        .padding(8)
                        .background(.thinMaterial, in: Circle())
                }
                .accessibilityLabel("About FindMeStat")

                // Details button
                Button {
                    showDetails = true
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 24, weight: .regular))
                        .padding(8)
                        .background(.thinMaterial, in: Circle())
                }
                .accessibilityLabel("Details FindMeStat")
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
        .sheet(isPresented: $showAbout) {
            AboutView()
                .presentationDetents([.medium])
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Capsule()
                .frame(width: 36, height: 5)
                .foregroundStyle(.secondary)
                .padding(.top, 8)

            Text("About FindMeStat")
                .font(.title3).bold()

            Text("Written by Steve Sheets for demonstration purposes.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Link("Full open source code on GitHub",
                 destination: URL(string: "https://github.com/magesteve/FindMeStat")!)
                .font(.body.weight(.semibold))
                .foregroundColor(.blue)

            Spacer()
        }
        .padding()
    }
}
