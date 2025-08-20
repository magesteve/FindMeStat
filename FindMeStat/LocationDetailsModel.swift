//
//  LocationDetailsModel.swift
//  FindMeStat
//
//  Created by Steve Sheets on 8/20/25.
//
//  Model of location details (observable for when geo
//  address is found).
//

// MARK: - Import

import SwiftUI
import CoreLocation

// MARK: - Class

/// Observable Model for Location details
@MainActor
final class LocationDetailsModel: ObservableObject {

    // MARK: - Published Properties
    
    @Published var addressDetails: String? = nil
    @Published var isLookingUp: Bool = false

}
