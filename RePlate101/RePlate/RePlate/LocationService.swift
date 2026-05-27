//
//  LocationService.swift
//  RePlate
//
//  Created by Jyotika Sadani on 5/27/26.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine

// MARK: - Private NSObject Delegate Shim
// Keeps CLLocationManagerDelegate (NSObject-based, non-isolated) separate
// from the @MainActor LocationService so Swift 6 actor isolation is satisfied.
private final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var onLocationUpdate: ((CLLocation) -> Void)?
    var onAuthorizationChange: ((CLAuthorizationStatus) -> Void)?
    var onError: ((Error) -> Void)?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocationUpdate?(location)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuthorizationChange?(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onError?(error)
    }
}

// MARK: - Location Service
class LocationService: ObservableObject {
    static let shared = LocationService()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationString: String = "San Francisco, CA"
    @Published var isLoading = false

    private let locationManager = CLLocationManager()
    private let locationDelegate = LocationManagerDelegate()

    private init() {
        authorizationStatus = locationManager.authorizationStatus

        locationDelegate.onLocationUpdate = { [weak self] location in
            Task { @MainActor [weak self] in
                self?.currentLocation = location
                self?.reverseGeocode(location)
                self?.locationManager.stopUpdatingLocation()
            }
        }

        locationDelegate.onAuthorizationChange = { [weak self] status in
            Task { @MainActor [weak self] in
                self?.authorizationStatus = status
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.locationManager.startUpdatingLocation()
                }
            }
        }

        locationDelegate.onError = { error in
            print("Location error: \(error.localizedDescription)")
        }

        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Request Permission
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    // MARK: - Start Updating Location
    func startUpdating() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            requestPermission()
            return
        }
        locationManager.startUpdatingLocation()
    }

    // MARK: - Stop Updating
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - Reverse Geocoding (iOS 26+: MKReverseGeocodingRequest)
    private func reverseGeocode(_ location: CLLocation) {
        isLoading = true
        Task { @MainActor [weak self] in
            defer { self?.isLoading = false }
            do {
                guard let request = MKReverseGeocodingRequest(location: location) else { return }
                let mapItems = try await request.mapItems
                if let placemark = mapItems.first?.placemark,
                   let city = placemark.locality,
                   let state = placemark.administrativeArea {
                    self?.locationString = "\(city), \(state)"
                }
            } catch {
                print("Reverse geocoding error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Calculate Distance
    func distance(to coordinate: CLLocationCoordinate2D) -> Double? {
        guard let current = currentLocation else { return nil }
        let target = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return current.distance(from: target) / 1609.34 // meters → miles
    }
}
