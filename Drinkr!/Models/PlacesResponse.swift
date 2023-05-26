//
//  PlacesResponse.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/19.
//

import Foundation

// struct Place {
//    let name: String
//    let identifier: String
// }

struct PlacesResponse: Codable {
    let htmlAttributions: [String]?
    let results: [Place]
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
    let location: Location
    let viewport: Viewport
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

struct Viewport: Codable {
    let northeast: Location
    let southwest: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}
