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
    
    public func searchNearbyBars(completion: @escaping (Result<Data, Error>) -> Void) {
        
        let location  = "25.044367149608902,121.53305163254714"
        let radius = 100000
        let type = "bar"
//        let language = "zh-TW"
        
        let api = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=\(radius)&type=\(type)&key=\(GMSPlacesAPIKey)"
        
        //&language=\(language)
        
        guard let url = URL(string: api) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                completion(.success(data))
            }
            
            if let response = response {
                
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
                        FFSManager.shared.addBarData(placeResponse: placesResponse.results)
                    } catch {
                        print("Decoding error: \(error)")
                    }
                case .failure(let error):
                    print("Error fetching data: \(error)")
                }
            }
    }
}
