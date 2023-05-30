//
//  GooglePlacesManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/20.
//

import Foundation
import GooglePlaces

enum PlacesError: Error {
    case failedToFind
    case failedToGetCoordinates
}

final class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    public let client = GMSPlacesClient.shared()
    
    private init() {}
    
    public func searchNearbyBars(with nextPageToken: String? = nil, completion: ((Result<Data, Error>) -> Void)? = nil) {
        
        let location  = "25.03028805128867,121.53062812349258"
        let radius = 50000
        let type = "bar"
        let language = "zh-TW"
        
        var api = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=\(radius)&language=\(language)&type=\(type)&key=\(GMSPlacesAPIKey)"
        
        if let nextPageToken = nextPageToken {
            api += "&pagetoken=\(nextPageToken)"
        }
        
        guard let url = URL(string: api) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let error = error {
                print("Error fetching next page: \(error)")
                completion?(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(PlacesResponse.self, from: data)
                    
                    completion?(.success(data))
                    
                    if let nextPageToken = response.nextPageToken {
                        // Request the next page if there is a next page token
                        self?.searchNearbyBars(with: nextPageToken)
                    }
                    
                } catch {
                    print("Error decoding response: \(error)")
                }
            }
        }
        task.resume()
    }
    
    func decodeBarDataToStoreFirebase() {
        self.searchNearbyBars { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                do {
                    let placesResponse = try decoder.decode(PlacesResponse.self, from: data)
                    FFSManager.shared.addBars(placeResponse: placesResponse.results)
                } catch {
                    print("Decoding error: \(error)")
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
}
