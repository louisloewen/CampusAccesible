// RouteView.swift
// CampusAccesible

import SwiftUI
import MapKit

private let campusCenter = CLLocationCoordinate2D(latitude: 25.6515, longitude: -100.289599)

struct RouteView: View {
    @Environment(CampusDataService.self) private var dataService
    @State private var viewModel = RouteViewModel()
    @State private var cameraPosition: MapCameraPosition = .camera(
        MapCamera(centerCoordinate: campusCenter, distance: 1500)
    )

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                if !viewModel.routeCoordinates.isEmpty {
                    MapPolyline(coordinates: viewModel.routeCoordinates)
                        .stroke(
                            viewModel.isAccessible ? Color.blue : Color.red,
                            lineWidth: 5
                        )
                }
                if let origin = viewModel.originCoordinate {
                    Marker("Origen", coordinate: origin)
                        .tint(.green)
                }
                if let destination = viewModel.destinationCoordinate {
                    Marker("Destino", coordinate: destination)
                        .tint(.red)
                }
                UserAnnotation()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .ignoresSafeArea(edges: .bottom)
            .onChange(of: viewModel.routeCoordinates) {
                fitCameraToRoute()
            }

            routeControlsOverlay(vm: viewModel)
        }
        .onAppear {
            viewModel.configure(with: dataService)
        }
        .onChange(of: viewModel.isAccessible) {
            viewModel.calculateRoute()
        }
    }

    @ViewBuilder
    private func routeControlsOverlay(vm: RouteViewModel) -> some View {
        @Bindable var bvm = vm
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                SuggestionTextField(
                    placeholder: "Origen",
                    text: $bvm.originText,
                    suggestions: vm.originSuggestions(),
                    onSelect: { vm.selectOrigin($0) }
                )

                SuggestionTextField(
                    placeholder: "Destino",
                    text: $bvm.destinationText,
                    suggestions: vm.destinationSuggestions(),
                    onSelect: { vm.selectDestination($0) }
                )

                HStack {
                    Label("Ruta accesible", systemImage: "figure.roll")
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Spacer()
                    Toggle("", isOn: $bvm.isAccessible)
                        .labelsHidden()
                        .tint(.blue)
                }
            }
            .padding(16)
            .glassEffect(.regular, in: .rect(cornerRadius: 18))
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 60)
    }

    private func fitCameraToRoute() {
        let coords = viewModel.routeCoordinates
        guard coords.count > 1 else { return }
        let lats = coords.map { $0.latitude }
        let lons = coords.map { $0.longitude }
        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLon = lons.min(), let maxLon = lons.max() else { return }
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5 + 0.002,
            longitudeDelta: (maxLon - minLon) * 1.5 + 0.002
        )
        withAnimation(.smooth) {
            cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
}

#Preview {
    RouteView()
        .environment(CampusDataService())
}
