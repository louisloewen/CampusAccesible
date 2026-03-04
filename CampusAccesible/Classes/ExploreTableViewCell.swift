// ExploreView.swift
// CampusAccesible

import SwiftUI

struct ExploreView: View {
    @Environment(CampusDataService.self) private var dataService

    private var sortedBuildings: [Building] {
        dataService.buildings.values
            .filter { $0.show }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            List(sortedBuildings) { building in
                NavigationLink(value: building) {
                    BuildingListRow(building: building)
                }
                .accessibilityLabel(building.name)
            }
            .navigationTitle("Explora")
            .navigationDestination(for: Building.self) { building in
                BuildingDetailView(building: building)
            }
        }
    }
}

private struct BuildingListRow: View {
    let building: Building

    var body: some View {
        HStack(spacing: 12) {
            Image(building.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(.circle)
            Text(building.name)
                .font(.body)
        }
    }
}

#Preview {
    ExploreView()
        .environment(CampusDataService())
}
