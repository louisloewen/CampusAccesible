// RouteViewModel.swift + SuggestionTextField.swift
// CampusAccesible

import SwiftUI
import MapKit
import Observation

@Observable
final class RouteViewModel {
    var originText = ""
    var destinationText = ""
    var isAccessible = false
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var originCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?

    private var originIndex: Int?
    private var destinationIndex: Int?
    private var pathfinder: PathfindingService?
    private weak var dataService: CampusDataService?

    /// Call once on appear — safe to call again (no-op after first call).
    func configure(with service: CampusDataService) {
        guard pathfinder == nil else { return }
        dataService = service
        pathfinder = PathfindingService(coordinates: service.coordinates, paths: service.paths)
    }

    func originSuggestions() -> [String] {
        guard !originText.isEmpty, let service = dataService else { return [] }
        return service.buildingNames.filter { $0.localizedCaseInsensitiveContains(originText) }
    }

    func destinationSuggestions() -> [String] {
        guard !destinationText.isEmpty, let service = dataService else { return [] }
        return service.buildingNames.filter { $0.localizedCaseInsensitiveContains(destinationText) }
    }

    func selectOrigin(_ name: String) {
        guard let service = dataService,
              let building = service.buildings[name],
              let index = building.coordIndices.first,
              index < service.coordinates.count else { return }
        originText = name
        originIndex = index
        originCoordinate = service.coordinates[index].clCoordinate
        calculateRoute()
    }

    func selectDestination(_ name: String) {
        guard let service = dataService,
              let building = service.buildings[name],
              let index = building.coordIndices.first,
              index < service.coordinates.count else { return }
        destinationText = name
        destinationIndex = index
        destinationCoordinate = service.coordinates[index].clCoordinate
        calculateRoute()
    }

    func calculateRoute() {
        guard let from = originIndex,
              let to = destinationIndex,
              let pf = pathfinder else {
            routeCoordinates = []
            return
        }
        routeCoordinates = pf.findPath(from: from, to: to, accessible: isAccessible)
    }
}

/// A text field that shows a filtered suggestion list below.
struct SuggestionTextField: View {
    let placeholder: String
    @Binding var text: String
    let suggestions: [String]
    let onSelect: (String) -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)

                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("Borrar \(placeholder)")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(.white.opacity(0.15), in: .rect(cornerRadius: 10))

            if isFocused && !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                        Button {
                            onSelect(suggestion)
                            isFocused = false
                        } label: {
                            Text(suggestion)
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                        }
                        if suggestion != suggestions.prefix(5).last {
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 10))
            }
        }
    }
}
