// PathfindingService.swift
// CampusAccesible
//
// Replaces the original Google Maps + GameplayKit PathCalculator.
// Pure GameplayKit graph — no map SDK dependency.

import GameplayKit
import CoreLocation

/// Builds weighted graphs from campus data and finds shortest paths.
final class PathfindingService {
    private var nodes: [PathNode] = []
    private var accessibleNodes: [PathNode] = []
    private let graph: GKGraph
    private let accessibleGraph: GKGraph

    init(coordinates: [CampusCoordinate], paths: [CampusPath]) {
        graph = GKGraph()
        accessibleGraph = GKGraph()

        for coord in coordinates {
            nodes.append(PathNode(latitude: coord.latitude, longitude: coord.longitude))
            accessibleNodes.append(PathNode(latitude: coord.latitude, longitude: coord.longitude))
        }
        graph.add(nodes)
        accessibleGraph.add(accessibleNodes)

        for path in paths {
            guard path.fromIndex < nodes.count, path.toIndex < nodes.count else { continue }
            let weight = Float(path.distance)
            nodes[path.fromIndex].addConnection(to: nodes[path.toIndex], weight: weight)
            if path.isAccessible {
                accessibleNodes[path.fromIndex].addConnection(
                    to: accessibleNodes[path.toIndex],
                    weight: weight
                )
            }
        }
    }

    /// Returns the ordered coordinates of the shortest path, or an empty array if unreachable.
    func findPath(from fromIndex: Int, to toIndex: Int, accessible: Bool) -> [CLLocationCoordinate2D] {
        guard fromIndex < nodes.count, toIndex < nodes.count else { return [] }
        let searchNodes = accessible ? accessibleNodes : nodes
        let searchGraph = accessible ? accessibleGraph : graph
        return searchGraph
            .findPath(from: searchNodes[fromIndex], to: searchNodes[toIndex])
            .compactMap { ($0 as? PathNode).map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }}
    }
}

final class PathNode: GKGraphNode {
    private var travelCost: [GKGraphNode: Float] = [:]
    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }

    required init?(coder: NSCoder) {
        latitude = 0
        longitude = 0
        super.init()
    }

    override func cost(to node: GKGraphNode) -> Float {
        travelCost[node] ?? 0
    }

    func addConnection(to node: GKGraphNode, bidirectional: Bool = true, weight: Float) {
        addConnections(to: [node], bidirectional: bidirectional)
        travelCost[node] = weight
        if bidirectional {
            (node as? PathNode)?.travelCost[self] = weight
        }
    }
}
