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
    
    init(from dictionary: [String: Any]) {
        businessStatus = dictionary["business_status"] as? String
        geometry = dictionary["geometry"] as? Geometry
        icon = dictionary["icon"] as? String
        iconBackgroundColor = dictionary["icon_background_color"] as? String
        iconMaskBaseURI = dictionary["icon_mask_base_uri"] as? String
        name = dictionary["name"] as? String
        openingHours = dictionary["opening_hours"] as? [String: Bool]
        photos = (dictionary["photos"] as? [[String: Any]])?.compactMap { Photo(from: $0) }
        placeID = dictionary["place_id"] as? String
        plusCode = dictionary["plus_code"] as? PlusCode
        priceLevel = dictionary["price_level"] as? Int
        rating = dictionary["rating"] as? Double
        reference = dictionary["reference"] as? String
        scope = dictionary["scope"] as? String
        types = dictionary["types"] as? [String]
        userRatingsTotal = dictionary["user_ratings_total"] as? Int
        vicinity = dictionary["vicinity"] as? String
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
    
    init(from dictionary: [String: Any]) {
        height = dictionary["height"] as? Int ?? 0
        htmlAttributions = dictionary["htmlAttributions"] as? [String] ?? []
        photoReference = dictionary["photoReference"] as? String ?? ""
        width = dictionary["width"] as? Int ?? 0
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
