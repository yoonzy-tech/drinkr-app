//
//  DPlacesResponse.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/9.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FavPlace: Codable {
    let placeID: String
    let addedTime: Timestamp?
    
    enum CodingKeys: String, CodingKey {
        case placeID = "place_id"
        case addedTime
    }
}

struct PlacesResponse: Codable {
    let htmlAttributions: [String]?
    let results: [Place]
    let nextPageToken: String?
    
    enum CodingKeys: String, CodingKey {
        case htmlAttributions
        case results
        case nextPageToken = "next_page_token"
    }
}

struct Place: Codable {
    let businessStatus: String?
    let geometry: Geometry?
    let icon: String?
    let iconBackgroundColor: String?
    let iconMaskBaseURI: String?
    let name: String?
    let openingHours: [String: Bool]?
    let photos: [Photo]?
    let placeID: String?
    let plusCode: PlusCode?
    let priceLevel: Int?
    let rating: Double?
    let reference: String?
    let scope: String?
    let types: [String]?
    let userRatingsTotal: Int?
    let vicinity: String?
    
    enum CodingKeys: String, CodingKey {
        case businessStatus = "business_status"
        case geometry, icon
        case iconBackgroundColor = "icon_background_color"
        case iconMaskBaseURI = "icon_mask_base_uri"
        case name
        case openingHours = "opening_hours"
        case photos
        case placeID = "place_id"
        case plusCode = "plus_code"
        case priceLevel = "price_level"
        case rating, reference, scope, types
        case userRatingsTotal = "user_ratings_total"
        case vicinity
    }
}

struct Geometry: Codable {
    let location: DLocation
    let viewport: DViewport
}

struct Photo: Codable {
    let height: Int
    let htmlAttributions: [String]
    let photoReference: String
    let width: Int
    
    enum CodingKeys: String, CodingKey {
        case height
        case htmlAttributions = "html_attributions"
        case photoReference = "photo_reference"
        case width
    }
}

struct PlusCode: Codable {
    let compoundCode: String
    let globalCode: String
    
    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}

struct DViewport: Codable {
    let northeast: DLocation
    let southwest: DLocation
}

struct DLocation: Codable {
    let lat: Double
    let lng: Double
}
