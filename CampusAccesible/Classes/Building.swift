// Building.swift
// CampusAccesible

import Foundation

struct Building: Identifiable, Hashable {
    let id: String
    let name: String
    let imageName: String
    /// nil means the building has no elevator information
    let hasElevator: Bool?
    let schedule: String
    let bathrooms: [Bathroom]
    let coordIndices: [Int]
    let show: Bool
}

struct Bathroom: Identifiable, Hashable {
    let id: String
    let name: String
    let isAccessible: Bool
}
