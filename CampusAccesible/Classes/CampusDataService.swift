// CampusPath.swift + CampusDataService.swift
// CampusAccesible

import Foundation
import Observation

struct CampusPath {
    let fromIndex: Int
    let toIndex: Int
    let isAccessible: Bool
    let distance: Double
}

/// Loads and vends all campus data from plist files.
@Observable
final class CampusDataService {
    let buildings: [String: Building]
    let buildingNames: [String]
    let coordinates: [CampusCoordinate]
    let paths: [CampusPath]

    init() {
        // Load coordinates.
        // Note: plist keys "longitud"/"latitud" are swapped by convention in the original data.
        // "longitud" contains latitude values (~25.xx) and "latitud" contains longitude values (~-100.xx).
        var coords: [CampusCoordinate] = []
        if let filePath = Bundle.main.path(forResource: "Coords", ofType: "plist"),
           let array = NSArray(contentsOfFile: filePath) {
            for (index, item) in array.enumerated() {
                if let dict = item as? NSDictionary,
                   let lat = dict["longitud"] as? Double,
                   let lon = dict["latitud"] as? Double {
                    coords.append(CampusCoordinate(id: index, latitude: lat, longitude: lon))
                }
            }
        }
        self.coordinates = coords

        // Load paths.
        var campusPaths: [CampusPath] = []
        if let filePath = Bundle.main.path(forResource: "ListaCaminos", ofType: "plist"),
           let array = NSArray(contentsOfFile: filePath) {
            for item in array {
                if let dict = item as? NSDictionary,
                   let from = dict["punto1"] as? Int,
                   let to = dict["punto2"] as? Int,
                   let accessible = dict["accesible"] as? Bool,
                   from < coords.count, to < coords.count {
                    let c1 = coords[from], c2 = coords[to]
                    let dx = c1.latitude - c2.latitude
                    let dy = c1.longitude - c2.longitude
                    campusPaths.append(CampusPath(
                        fromIndex: from,
                        toIndex: to,
                        isAccessible: accessible,
                        distance: sqrt(dx * dx + dy * dy)
                    ))
                }
            }
        }
        self.paths = campusPaths

        // Load buildings.
        var buildingMap: [String: Building] = [:]
        if let filePath = Bundle.main.path(forResource: "ListaEdificios", ofType: "plist"),
           let array = NSArray(contentsOfFile: filePath) {
            for item in array {
                if let dict = item as? NSDictionary,
                   let name = dict["nombre"] as? String,
                   let imageName = dict["imagen"] as? String,
                   let schedule = dict["horario"] as? String,
                   let bathroomsRaw = dict["banos"] as? NSArray,
                   let coordIndices = dict["coord"] as? [Int],
                   let show = dict["show"] as? Bool {
                    let hasElevator = dict["elevador"] as? Bool
                    let bathrooms: [Bathroom] = bathroomsRaw.compactMap { item in
                        guard let b = item as? NSDictionary,
                              let bName = b["nombre"] as? String,
                              let accessible = b["ambulatorio"] as? Bool else { return nil }
                        return Bathroom(id: bName, name: bName, isAccessible: accessible)
                    }
                    buildingMap[name] = Building(
                        id: name,
                        name: name,
                        imageName: imageName,
                        hasElevator: hasElevator,
                        schedule: schedule,
                        bathrooms: bathrooms,
                        coordIndices: coordIndices,
                        show: show
                    )
                }
            }
        }
        self.buildings = buildingMap
        self.buildingNames = buildingMap.values
            .filter { $0.show }
            .map { $0.name }
            .sorted()
    }
}
