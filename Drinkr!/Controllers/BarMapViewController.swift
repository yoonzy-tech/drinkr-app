//
//  ViewController.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/19.
//

import UIKit
import MapKit
import CoreLocation
import Kingfisher

class BarMapViewController: UIViewController {
    
    // Bar Card Collection View Var
    var dataSource: [[String: Any]] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Search Controller Var
    let searchVC = UISearchController(searchResultsController: ResultsViewController())
    
    // Map View Var
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func refetchNearbyBars(_ sender: Any) {
        locationManager.requestLocation()
        showNearbyBarsToUser()
    }
    
    @IBAction func relocateUserPosition(_ sender: Any) {
        locationManager.requestLocation()
        showNearbyBarsToUser()
    }
    
    // Core Location Var
    let locationManager = CLLocationManager()
    var userCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Search Controller Setup
//        searchVC.searchBar.backgroundColor = UIColor(red: 23/255, green: 44/255, blue: 211/255, alpha: 1.0)
//        searchVC.searchBar.searchTextField.backgroundColor = .white
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        // Core Location Setup, Permission
        locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.requestWhenInUseAuthorization()
        
        if locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways {
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
            showNearbyBarsToUser()
        }
        mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let annotation = view.annotation as? MKPointAnnotation {
                let tappedCoordinates = annotation.coordinate
                let correspondingIndex = calculateCorrespondingIndex(for: tappedCoordinates)
                scrollToCollectionViewCell(at: correspondingIndex)
            }
        }
    
    func calculateCorrespondingIndex(for coordinates: CLLocationCoordinate2D) -> Int {
        // Iterate through your annotations or overlays and find the matching coordinates
        for (index, annotation) in dataSource.enumerated() {
            if annotation["latitude"] as? Double == coordinates.latitude &&
                annotation["longitude"] as? Double == coordinates.longitude {
                return index
            }
        }
        return 0 // Default index if no match is found
    }
    
    func scrollToCollectionViewCell(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
}

// MARK: - Map Pins
extension BarMapViewController: MKMapViewDelegate {
    func showNearbyBarsToUser() {
        mapView.showsUserLocation = true
        generateMapPins(with: userCoordinates)
    }
    
    func generateMapPins(with userLocation: CLLocationCoordinate2D) {
        // Remove all map pins
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        
        // Fetch Nearby Bars Locations
        FFSManager.shared.fetchBars { [weak self] places in
            // Add a map pin
            for place in places {
                guard let placeInfo = place.placeInfo as? [String: Any],
                      let latitude = placeInfo["latitude"] as? CLLocationDegrees,
                      let longitude = placeInfo["longitude"] as? CLLocationDegrees
                else { return }
                self?.dataSource.append(placeInfo)
                
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude)
                pin.title = placeInfo["name"] as? String
                pin.subtitle = String(placeInfo["rating"] as? Double ?? 0)

                self?.mapView.addAnnotation(pin)
            }
            
            // Bar Card Collection View
            self?.collectionView.dataSource = self
            self?.collectionView.delegate = self
            
            self?.zoomInUserLocation()
        }
    }
    
    func zoomInUserLocation() {
        // Zoom in to User Location
        self.mapView.setRegion(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ), animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "custom")
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "custom")
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: "beer jar")
        return annotationView
    }
}

// MARK: - Core Location Manager
extension BarMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            print("LocationManager didChangeAuthorization denied")
        case .notDetermined:
            print("LocationManager didChangeAuthorization notDetermined")
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            print("LocationManager didChangeAuthorization authorizedWhenInUse")
            locationManager.requestLocation()
            self.locationManager.startUpdatingLocation()
            showNearbyBarsToUser()
        case .authorizedAlways:
            print("LocationManager didChangeAuthorization authorizedAlways")
            locationManager.requestLocation()
            self.locationManager.startUpdatingLocation()
            showNearbyBarsToUser()
        case .restricted:
            print("LocationManager didChangeAuthorization restricted")
        default:
            print("LocationManager didChangeAuthorization")
        }
    }
    
    // Store user latitude & longitude
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
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
extension BarMapViewController: UISearchResultsUpdating, ResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? ResultsViewController
        else { return }
        resultVC.delegate = self
        FFSManager.shared.findBars(query: query) { documents in
            let places = documents.compactMap { $0.data() }
            DispatchQueue.main.async {
                resultVC.update(with: places)
            }
        }
    }
    
    func didTapPlace(with coordinates: CLLocationCoordinate2D, name: String) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.searchBar.text = name
        searchVC.dismiss(animated: true)
        self.mapView.setRegion(MKCoordinateRegion(
            center: coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ), animated: true)
        let correspondingIndex = calculateCorrespondingIndex(for: coordinates)
        scrollToCollectionViewCell(at: correspondingIndex)
    }
}

// MARK: - Bar Place Card Collection View
extension BarMapViewController: UICollectionViewDataSource,
                                UICollectionViewDelegate,
                                UICollectionViewDelegateFlowLayout,
                                UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BarCardCollectionViewCell", for: indexPath) as? BarCardCollectionViewCell
        else { fatalError("Unable to generate Bar Card Collection View Cell") }
        
        cell.placeNameLabel.text = dataSource[indexPath.row]["name"] as? String
        cell.placeAddressLabel.text = dataSource[indexPath.row]["vicinity"] as? String
        if let rating = dataSource[indexPath.row]["rating"] as? Double {
            cell.placeRatingOpenHourLabel.text = rating > 0 ? "\(rating) Stars" : "No ratings"
        }
        
        if let barLatitude = dataSource[indexPath.row]["latitude"] as? Double,
           let barLongitude = dataSource[indexPath.row]["longitude"] as? Double {
            let distance = calculateDistance(
                lat1: userCoordinates.latitude,
                lon1: userCoordinates.longitude,
                lat2: barLatitude,
                lon2: barLongitude
            )
            cell.placeDistanceLabel.text = "\(distance) km away"
        }
        
        cell.directionButton.tag = indexPath.row
        cell.directionButton.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        cell.saveButton.tag = indexPath.row
        cell.saveButton.addTarget(self, action: #selector(saveToFavorite), for: .touchUpInside)
        
        return cell
    }
}

// MARK: Cell Buttons Actions, Calculations
extension BarMapViewController {
    func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let coordinate1 = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate2 = CLLocation(latitude: lat2, longitude: lon2)
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        let distanceInKilometers = distanceInMeters / 1000.0
        let roundedDistance = (distanceInKilometers * 100).rounded() / 100
        return roundedDistance
    }
    
    // TODO: Save place to favorite
    @objc func saveToFavorite(_ sender: UIButton) {
        
    }
    
    @objc func getDirections(_ sender: UIButton) {
        
        let index = sender.tag
        
        guard let desLat = self.dataSource[index]["latitude"],
              let desLon = self.dataSource[index]["longitude"],
              let placeId = self.dataSource[index]["placeId"] else {
            print("Error in getting user or destination location")
            return
        }
        
        let userCoordinates = "\(self.userCoordinates.latitude),\(self.userCoordinates.longitude)"
        
        let destinationCoordinates = "\(desLat),\(desLon)"
        
        // Create Action Sheet
       let actionSheetController: UIAlertController = UIAlertController(
        title: nil,
        message: "What would you like to do?",
        preferredStyle: .actionSheet)

        // TODO: Action 1 - Copy Address
        let firstAction: UIAlertAction = UIAlertAction(
            title: "Copy Address",
            style: .default) { _ in
                print("Copy Address Action pressed")
            }
        
        // Action 2 - Open Direction in Apple Maps
        let secondAction: UIAlertAction = UIAlertAction(
            title: "Open in Apple Maps",
            style: .default)
        { _ in
            let directionsURLString = "http://maps.apple.com/?saddr=\(userCoordinates)&daddr=\(destinationCoordinates)"
            guard let directionsURL = URL(string: directionsURLString) else { return }
            UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
        }
        
        // Action 3 - Open Direction in Goolge Maps
        let thirdAction: UIAlertAction = UIAlertAction(
            title: "Open in Google Maps",
            style: .default)
        { _ in
            let directionURLString = "https://www.google.com/maps/search/?api=1&query=\(destinationCoordinates)&query_place_id=\(placeId)"
            guard let directionURL = URL(string: directionURLString) else { return }
            UIApplication.shared.open(directionURL, options: [:], completionHandler: nil)
        }
        
        // Default Action - Cancel
        let cancelAction: UIAlertAction = UIAlertAction(
            title: "Cancel",
            style: .cancel)

        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(thirdAction)
        actionSheetController.addAction(cancelAction)

        actionSheetController.popoverPresentationController?.sourceView = self.view
        
        self.present(actionSheetController, animated: true) {
            print("option menu presented")
        }
    }
}
