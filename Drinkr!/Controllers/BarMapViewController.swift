//
//  ViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/19.
//

import UIKit
import MapKit
import CoreLocation

class BarMapViewController: UIViewController {

    let mapView = MKMapView()

    let searchVC = UISearchController(searchResultsController: ResultsViewController())

    let locationManager = CLLocationManager()

    var userCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bar Map"
        view.addSubview(mapView)
//        searchVC.searchBar.backgroundColor = .white
//        searchVC.searchResultsUpdater = self
//        navigationItem.searchController = searchVC

        /// Ask Permission to Retrieve User Location
        locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        
        if locationManager.authorizationStatus != .denied || locationManager.authorizationStatus != .notDetermined {
            showNearbyBarsToUser()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.frame.size.width,
            height: view.frame.size.height - view.safeAreaInsets.top)
    }

}

// MARK: - Map Pins & User Location
extension BarMapViewController {
    func showNearbyBarsToUser() {
        mapView.showsUserLocation = true
        generateMapPins(with: userCoordinates)
    }
    
    func generateMapPins(with userLocation: CLLocationCoordinate2D) {

        // Remove all map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)

        // Fetch Nearby Bars Locations
        FFSManager.shared.readBarData { [weak self] places in

            // Add a map pin
            for place in places {
                guard let placeInfo = place.placeInfo as? [String: Any],
                        let latitude = placeInfo["latitude"] as? CLLocationDegrees,
                        let longitude = placeInfo["longitude"] as? CLLocationDegrees
                else { return }

                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude)

                self?.mapView.addAnnotation(pin)
            }

            self?.mapView.setRegion(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 25.044367149608902, longitude: 121.53305163254714),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ), animated: true)
        }
    }
}

// MARK: - Apple System Location Manager
extension BarMapViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {

        case .denied: /// Setting option: Never
            print("LocationManager didChangeAuthorization denied")

        case .notDetermined: /// Setting option: Ask Next Time
            print("LocationManager didChangeAuthorization notDetermined")

        case .authorizedWhenInUse: /// Setting option: While Using the App
            print("LocationManager didChangeAuthorization authorizedWhenInUse")
            locationManager.requestLocation()
            self.locationManager.startUpdatingLocation()
            showNearbyBarsToUser()

        case .authorizedAlways: /// Setting option: Always
            print("LocationManager didChangeAuthorization authorizedAlways")
            locationManager.requestLocation()
            self.locationManager.startUpdatingLocation()
            showNearbyBarsToUser()

        case .restricted: /// Restricted by parental control
            print("LocationManager didChangeAuthorization restricted")

        default:
            print("LocationManager didChangeAuthorization")
        }
    }
    
    // Store user latitude & longitude
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//        print("Coordinates: \(locationValue.latitude), \(locationValue.longitude)")

        userCoordinates = locationValue
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        print("LocationManager didFailWithError \(error.localizedDescription)")

        if let error = error as? CLError, error.code == .denied {
            // Location updates are not authorized.
            // To prevent forever looping of `didFailWithError` callback
            locationManager.stopMonitoringSignificantLocationChanges()
            return
        }
    }
}

// MARK: - Search Results Updating
extension BarMapViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty
//              let resultVC = searchController.searchResultsController as? ResultsViewController
        else { return }
//        resultVC.delegate = self
    }

}
