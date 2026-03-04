// CreditsView.swift
// CampusAccesible

import SwiftUI

struct CreditsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .accessibilityLabel("ExploraTec logo")

                    VStack(alignment: .leading, spacing: 4) {
                        Text("ExploraTec")
                            .font(.largeTitle.bold())
                        Text("Campus Accesible — Tec de Monterrey")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Equipo de Desarrollo")
                            .font(.headline)

                        CreditRow(name: "Joao Gabriel Moura De Almeida", role: "Desarrollo iOS")
                        CreditRow(name: "Luis Villarreal", role: "Desarrollo iOS")
                        CreditRow(name: "Arturo González", role: "Desarrollo iOS")
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tecnologías")
                            .font(.headline)
                        Text("SwiftUI · MapKit · GameplayKit")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Créditos")
        }
    }
}

private struct CreditRow: View {
    let name: String
    let role: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.body)
            Text(role)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CreditsView()
}
