//
//  DrinkrTestCase.swift
//  Drinkr!Tests
//
//  Created by Ruby Chew on 2023/6/27.
//

import XCTest
import CoreLocation

@testable import Drinkr_

// swiftlint:disable line_length
final class DrinkrTestCase: XCTestCase {
    
    func testCalculateCorrespondingIndex() {
        // Create test data
        let coordinate1 = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let coordinate2 = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let coordinate3 = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        
        let place1 = Place(businessStatus: "Open", geometry: Geometry(location: DLocation(lat: 37.7749, lng: -122.4194), viewport: DViewport(northeast: DLocation(lat: 37.7749, lng: -122.4194), southwest: DLocation(lat: 37.7749, lng: -122.4194))), icon: "icon1", iconBackgroundColor: "color1", iconMaskBaseURI: "mask1", name: "Place 1", openingHours: ["Monday": true, "Tuesday": true], photos: [Photo(height: 200, htmlAttributions: ["Attribution 1"], photoReference: "ref1", width: 300)], placeID: "place1", plusCode: PlusCode(compoundCode: "code1", globalCode: "global1"), priceLevel: 2, rating: 4.5, reference: "ref1", scope: "scope1", types: ["type1", "type2"], userRatingsTotal: 100, vicinity: "Address 1")

        let place2 = Place(businessStatus: "Closed", geometry: Geometry(location: DLocation(lat: 40.7128, lng: -74.0060), viewport: DViewport(northeast: DLocation(lat: 40.7128, lng: -74.0060), southwest: DLocation(lat: 40.7128, lng: -74.0060))), icon: "icon2", iconBackgroundColor: "color2", iconMaskBaseURI: "mask2", name: "Place 2", openingHours: ["Monday": false, "Tuesday": false], photos: [Photo(height: 250, htmlAttributions: ["Attribution 2"], photoReference: "ref2", width: 400)], placeID: "place2", plusCode: PlusCode(compoundCode: "code2", globalCode: "global2"), priceLevel: 3, rating: 4.0, reference: "ref2", scope: "scope2", types: ["type3", "type4"], userRatingsTotal: 50, vicinity: "Address 2")
        
        let place3 = Place(businessStatus: "Closed", geometry: Geometry(location: DLocation(lat: 51.5074, lng: -0.1278), viewport: DViewport(northeast: DLocation(lat: 51.5074, lng: -0.1278), southwest: DLocation(lat: 51.5074, lng: -0.1278))), icon: "icon2", iconBackgroundColor: "color2", iconMaskBaseURI: "mask2", name: "Place 2", openingHours: ["Monday": false, "Tuesday": false], photos: [Photo(height: 250, htmlAttributions: ["Attribution 2"], photoReference: "ref2", width: 400)], placeID: "place2", plusCode: PlusCode(compoundCode: "code2", globalCode: "global2"), priceLevel: 3, rating: 4.0, reference: "ref2", scope: "scope2", types: ["type3", "type4"], userRatingsTotal: 50, vicinity: "Address 2")
        
        var fakeData: [Place] = []
        fakeData.append(place1)
        fakeData.append(place2)
        fakeData.append(place3)
        
        let barMapVC = BarMapViewController()
        barMapVC.dataSource = fakeData
        
        XCTAssertEqual(barMapVC.calculateCorrespondingIndex(for: coordinate1), 0)
        XCTAssertEqual(barMapVC.calculateCorrespondingIndex(for: coordinate2), 1)
        XCTAssertEqual(barMapVC.calculateCorrespondingIndex(for: coordinate3), 2)
    }
    
    func testBarDistance() {
        let cell = BarCardCollectionViewCell()
        
        let userLocation: [String: Double] = ["latitude": 25.038635, "longitude": 121.532402]
        let placeLocation: [String: Double] = ["latitude": 25.0285696, "longitude": 121.5210357]
        
        let distance = cell.calculateDistance(lat1: userLocation["latitude"] ?? 0,
                                              lon1: userLocation["longitude"] ?? 0,
                                              lat2: placeLocation["latitude"] ?? 0,
                                              lon2: placeLocation["longitude"] ?? 0)
        
        XCTAssertEqual(distance, 1.6)
    }
}
// swiftlint:enable line_length
