# FindMeStat README.md

A tiny SwiftUI + MapKit demo that shows your current location with a red flag pin, recenters on demand, and reveals a sliding details sheet with formatted GPS info and a reverse-geocoded address.

## Features

- SwiftUI `Map` with custom “flag” annotation at the user’s location  
- One-tap recenter button  
- Bottom sheet (resizable) with:
  - Latitude / Longitude
  - Altitude
  - Horizontal & vertical accuracy
  - Speed & course
  - Timestamp (localized)
  - **Reverse-geocoded address** (async; live-updates)
- Architecture:
  - `LocationManager` (singleton, publishes `CLLocation`)
  - `GeoAddressManager` (singleton, reverse-geocode + in-memory cache)
  - `LocationDetailsModel` (UI state only)
  - `FindMeStatMapView` (reusable Map component)

---

## Requirements

- Xcode 15+
- iOS 17+ (uses `MapCameraPosition` and SwiftUI Map annotations)
- Swift 5.9+

> You can drop the deployment target to iOS 16 with minor Map tweaks, but this project targets iOS 17.

---

## Permissions (Info.plist)

Add this key (Target → Info → Custom iOS Target Properties):

- **Privacy – Location When In Use Usage Description** (`NSLocationWhenInUseUsageDescription`)  
  Value example:  
  `We use your location to show your position on the map.`

No additional entitlements are required.

---

## Build & Run

1. Open the project in Xcode.
2. Ensure your **Deployment Target** is iOS 17.0 or higher.
3. Build & run on a device or the iOS Simulator.

### Simulator notes
- The simulator uses **simulated** GPS. In the Simulator menu:
  - **Features → Location** → select a preset or **Custom Location…**
- The address and telemetry will reflect the simulated position.

---

## How it works

### Location pipeline
- `LocationManager.shared` requests authorization and publishes `lastLocation`.
- `FindMeStatMapView` observes `lastLocation` and:
  - Centers the camera when the **first** fix arrives
  - Shows a red flag annotation at the user coordinate
- Tapping the flag triggers `ContentView` to present `LocationDetailsView`.

### Address lookup
- `LocationDetailsView` starts a lookup when shown (and whenever the `location.timestamp` changes).  
- `GeoAddressManager` reverse-geocodes with `CLGeocoder`, formats a single-line address, and caches results by rounded lat/lon (~1 m precision).
- Results are delivered on the **main thread** and published through `LocationDetailsModel`.

---

##Credits
- Built with SwiftUI, MapKit, and Core Location.
- Created by **Steve Sheets**, 8/20/25.

---

## Screen Shots

[iPhone 16 Map Screenshot](screenshots/FindMeState-iPhoneMap.png)

[iPhone 16 Detail Screenshot](screenshots/FindMeState-iPhoneDetails.png)

[iPad Map Screenshot](screenshots/FindMeState-iPadMap.png)

[iPad Details Screenshot](screenshots/FindMeState-iPadDetails.png)

