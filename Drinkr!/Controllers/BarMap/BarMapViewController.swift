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

    var user = FirebaseManager.shared.userData {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var barsDataSource: [[String: Any]] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    let searchVC = UISearchController(searchResultsController: BarResultsViewController())
    let locationManager = CLLocationManager()
    var userCoordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var relocationUserButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func refetchNearbyBars(_ sender: Any) {
        locationManager.requestLocation()
        showNearbyBarsToUser()
    }
    
    @IBAction func relocateUserPosition(_ sender: Any) {
        locationManager.requestLocation()
        showNearbyBarsToUser()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addShadow(relocationUserButton)
        addShadow(refreshButton)
        // Search Bar Setup
        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
        navigationItem.searchController = searchVC
        // Core Location Setup
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
}

// MARK: - Map Pins
extension BarMapViewController: MKMapViewDelegate {
    private func showNearbyBarsToUser() {
        guard let uid = FirebaseManager.shared.userUid else {
            print("Error getting Uid")
            return
        }
        // Fetch User Data before getting the bars data
        FirebaseManager.shared.fetchAccountInfo(uid: uid) { user in
            self.user = user
            self.mapView.showsUserLocation = true
            self.generateMapPins(with: self.userCoordinates)
        }
    }
    
    private func generateMapPins(with userLocation: CLLocationCoordinate2D) {
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
                self?.barsDataSource.append(placeInfo)
                
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
    
    private func zoomInUserLocation() {
        self.mapView.setRegion(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: userCoordinates.latitude, longitude: userCoordinates.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ), animated: true)
    }
    
    private func calculateCorrespondingIndex(for coordinates: CLLocationCoordinate2D) -> Int {
        // Iterate through annotations or overlays and find the matching coordinates
        for (index, annotation) in barsDataSource.enumerated() {
            if annotation["latitude"] as? Double == coordinates.latitude &&
                annotation["longitude"] as? Double == coordinates.longitude {
                return index
            }
        }
        return 0 // Default index if no match is found
    }
    
    private func scrollToCollectionViewCell(at index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func findMapPin(withCoordinates coordinates: CLLocationCoordinate2D) -> MKPointAnnotation? {
        for annotation in mapView.annotations {
            if let pinAnnotation = annotation as? MKPointAnnotation {
                if pinAnnotation.coordinate.latitude == coordinates.latitude &&
                    pinAnnotation.coordinate.longitude == coordinates.longitude {
                    return pinAnnotation
                }
            }
        }
        return nil
    }
    
    private func getAnnotationView(forAnnotation annotation: MKPointAnnotation) -> MKAnnotationView? {
        if let annotationView = mapView.view(for: annotation) {
            return annotationView
        }
        return nil
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            animateAnnotation(annotation, view: view)
            let tappedCoordinates = annotation.coordinate
            let correspondingIndex = calculateCorrespondingIndex(for: tappedCoordinates)
            scrollToCollectionViewCell(at: correspondingIndex)
        }
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
extension BarMapViewController: UISearchResultsUpdating, BarResultsViewControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultVC = searchController.searchResultsController as? BarResultsViewController
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let annotation = self.findMapPin(withCoordinates: coordinates) {
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
}

// MARK: - Bar Place Card Collection View
extension BarMapViewController: UICollectionViewDataSource,
                                UICollectionViewDelegate,
                                UICollectionViewDelegateFlowLayout,
                                UIScrollViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return barsDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BarCardCollectionViewCell", for: indexPath) as? BarCardCollectionViewCell
        else { fatalError("Unable to generate Bar Card Collection View Cell") }
        
        cell.placeNameLabel.text = barsDataSource[indexPath.row]["name"] as? String
        cell.placeAddressLabel.text = barsDataSource[indexPath.row]["vicinity"] as? String
        if let rating = barsDataSource[indexPath.row]["rating"] as? Double {
            cell.placeRatingOpenHourLabel.text = rating > 0 ? "\(rating) Stars" : "No ratings"
        }
        if let barLatitude = barsDataSource[indexPath.row]["latitude"] as? Double,
           let barLongitude = barsDataSource[indexPath.row]["longitude"] as? Double {
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
        if let placeId = barsDataSource[indexPath.row]["placeId"] as? String,
           let bool = user?.placeFavorite.contains(placeId) {
            cell.saveButton.imageView?.image = bool ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screen = UIScreen.main.bounds
        let screenWidth = screen.size.width
        return CGSize(width: screenWidth - 20, height: 145)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let visibleCellIndexs = collectionView.indexPathsForVisibleItems
        let cellIsPresenting = visibleCellIndexs.contains { $0 == indexPath }
        
        print("Visible Cells Indexes: \(visibleCellIndexs)")
        print("Current Tapped Cell IndexPath: \(indexPath)")
        
        
        if let barLatitude = barsDataSource[indexPath.row]["latitude"] as? Double,
           let barLongitude = barsDataSource[indexPath.row]["longitude"] as? Double,
           let annotation = findMapPin(withCoordinates:
                                        CLLocationCoordinate2D(latitude: barLatitude, longitude: barLongitude)),
           let annotationView = mapView.view(for: annotation) {
            self.mapView.setRegion(MKCoordinateRegion(
                center: annotation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ), animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.animateAnnotation(annotation, view: annotationView)
                self.mapView.selectAnnotation(annotation, animated: true)
            }
        }
//        // TODO: Cannot find pin on tap
        print("Cannot find pin")
    }
}

// MARK: Bard Card Utils
extension BarMapViewController {
    func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let coordinate1 = CLLocation(latitude: lat1, longitude: lon1)
        let coordinate2 = CLLocation(latitude: lat2, longitude: lon2)
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        let distanceInKilometers = distanceInMeters / 1000.0
        let roundedDistance = (distanceInKilometers * 100).rounded() / 100
        return roundedDistance
    }
    
    @objc func saveToFavorite(_ sender: UIButton) {
        let indexPath = IndexPath(item: sender.tag, section: 0)
        
        guard let placeId = barsDataSource[sender.tag]["placeId"] as? String else {
            print("Failed downcasting")
            return
        }
        guard var placeFavorite = user?.placeFavorite as? [String] else {
            print("Failed to convert place favorite")
            return
        }
        guard var saved = user?.placeFavorite.contains(placeId) else {
            print("Saved: is Nil")
            return
        }
        guard let cell = collectionView.cellForItem(at: indexPath) as? BarCardCollectionViewCell else {
            print("Button weird")
            return
        }
        
        saved = !saved
        cell.saveButton.setImage(saved ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart"), for: .normal)
        saved ? (placeFavorite.append(placeId)) : (placeFavorite.removeAll { $0 == placeId })
        user?.placeFavorite = placeFavorite
        FirebaseManager.shared.update(in: .users, docId: user?.id ?? "", data: self.user)
    }
    
    @objc func getDirections(_ sender: UIButton) {
        let index = sender.tag
        guard let desLat = self.barsDataSource[index]["latitude"],
              let desLon = self.barsDataSource[index]["longitude"],
              let placeId = self.barsDataSource[index]["placeId"] else {
            print("Error in getting user or destination location")
            return
        }
        
        let userCoordinates = "\(self.userCoordinates.latitude),\(self.userCoordinates.longitude)"
        let destinationCoordinates = "\(desLat),\(desLon)"
        
        let actionSheetController: UIAlertController = UIAlertController(
            title: nil, message: "What would you like to do?", preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(
            title: "Copy Address", style: .default) { _ in
                print("Copy Address Action pressed")
                UIPasteboard.general.string = self.barsDataSource[index]["vicinity"] as? String
            }
        let secondAction: UIAlertAction = UIAlertAction(
            title: "Open in Apple Maps", style: .default) { _ in
                let directionsURLString = "http://maps.apple.com/?saddr=\(userCoordinates)&daddr=\(destinationCoordinates)"
                guard let directionsURL = URL(string: directionsURLString) else { return }
                UIApplication.shared.open(directionsURL, options: [:], completionHandler: nil)
            }
        let thirdAction: UIAlertAction = UIAlertAction(
            title: "Open in Google Maps",
            style: .default) { _ in
                let directionURLString = "https://www.google.com/maps/search/?api=1&query=\(destinationCoordinates)&query_place_id=\(placeId)"
                guard let directionURL = URL(string: directionURLString) else { return }
                UIApplication.shared.open(directionURL, options: [:], completionHandler: nil)
            }
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

// MARK: UI Setup
extension BarMapViewController {
    private func addShadow(_ button: UIButton) {
        button.layer.masksToBounds = false
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        button.layer.shadowRadius = 4
        button.layer.cornerRadius = 5
    }
    
    private func animateAnnotation(_ annotation: MKPointAnnotation, view: MKAnnotationView) {
        let duration: TimeInterval = 0.4
        let bounceHeight: CGFloat = 15.0
        
        let originalCoordinate = annotation.coordinate
        let finalCoordinate = CLLocationCoordinate2D(
            latitude: originalCoordinate.latitude + 0.00001,
            longitude: originalCoordinate.longitude)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [], animations: {
            // Animation keyframes
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                annotation.coordinate = finalCoordinate
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.2, relativeDuration: 0.4) {
                annotation.coordinate = originalCoordinate
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.4, relativeDuration: 0.6) {
                annotation.coordinate = CLLocationCoordinate2D(
                    latitude: originalCoordinate.latitude + 0.00001,
                    longitude: originalCoordinate.longitude)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 1.0) {
                annotation.coordinate = originalCoordinate
            }
        }, completion: nil)
        
        let keyframeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        keyframeAnimation.values = [0, -bounceHeight, 0]
        keyframeAnimation.keyTimes = [0, 0.5, 1]
        keyframeAnimation.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeIn)
        ]
        keyframeAnimation.duration = duration
        view.layer.add(keyframeAnimation, forKey: "bounceAnimation")
    }
}
