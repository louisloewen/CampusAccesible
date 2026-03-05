// ContentView.swift
// CampusAccesible

import SwiftUI

struct ContentView: View {
    @State private var dataService = CampusDataService()

    var body: some View {
        TabView {
            Tab("Explora", systemImage: "building.2") {
                ExploreView()
            }
            Tab("Ruta", systemImage: "map") {
                RouteView()
            }
            Tab("Créditos", systemImage: "info.circle") {
                CreditsView()
            }
        }
        .environment(dataService)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
}
