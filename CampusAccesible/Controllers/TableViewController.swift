// BuildingDetailView.swift + BathroomsView.swift
// CampusAccesible

import SwiftUI

struct BuildingDetailView: View {
    let building: Building

    var body: some View {
        List {
            Section {
                Image(building.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                    .clipped()
                    .listRowInsets(EdgeInsets())
                    .accessibilityLabel("Imagen de \(building.name)")
            }

            Section("Horario") {
                Label(building.schedule, systemImage: "clock")
            }

            if let hasElevator = building.hasElevator {
                Section("Elevador") {
                    Label(
                        hasElevator ? "Disponible" : "No disponible",
                        systemImage: hasElevator ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .foregroundStyle(hasElevator ? .green : .red)
                }
            }

            if !building.bathrooms.isEmpty {
                Section("Baños") {
                    NavigationLink("Ver baños accesibles") {
                        BathroomsView(building: building)
                    }
                }
            }
        }
        .navigationTitle(building.name)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct BathroomsView: View {
    let building: Building

    var body: some View {
        List(building.bathrooms) { bathroom in
            HStack {
                Text(bathroom.name)
                    .font(.body)
                Spacer()
                if bathroom.isAccessible {
                    Label("Accesible", systemImage: "figure.roll")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.blue)
                        .accessibilityLabel("Baño accesible")
                }
            }
        }
        .navigationTitle("Baños")
        .navigationBarTitleDisplayMode(.inline)
    }
}
