//
//  GooglePlacesManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/20.
//

import Foundation
import Alamofire
import GooglePlaces

enum PlacesError: Error {
    case failedToFind
    case failedToGetCoordinates
}

final class GooglePlacesManager {
    
    static let shared = GooglePlacesManager()
    
    public let client = GMSPlacesClient.shared()
    
    private init() {}

    //    public func searchNearbyBars(with nextPageToken: String? = nil, completion: ((Result<Data, Error>) -> Void)? = nil) {
    //
    //        let location  = "25.03028805128867,121.53062812349258"
    //        let radius = 50000
    //        let type = "bar"
    //        let language = "zh-TW"
    //
    //        var api = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=\(radius)&language=\(language)&type=\(type)&key=\(GMSPlacesAPIKey)"
    //
    //        if let nextPageToken = nextPageToken {
    //            api += "&pagetoken=\(nextPageToken)"
    //        }
    //
    //        guard let url = URL(string: api) else {
    //            print("Invalid URL")
    //            return
    //        }
    //
    //        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
    //            if let error = error {
    //                print("Error fetching next page: \(error)")
    //                completion?(.failure(error))
    //                return
    //            }
    //
    //            if let data = data {
    //                do {
    //                    let decoder = JSONDecoder()
    //                    let response = try decoder.decode(PlacesResponse.self, from: data)
    //
    //                    completion?(.success(data))
    //
    //                    if let nextPageToken = response.nextPageToken {
    //                        // Request the next page if there is a next page token
    //                        self?.searchNearbyBars(with: nextPageToken)
    //                    }
    //
    //                } catch {
    //                    print("Error decoding response: \(error)")
    //                }
    //            }
    //        }
    //        task.resume()
    //    }
    //
    //    func decodeBarDataToStoreFirebase() {
    //        self.searchNearbyBars { result in
    //            switch result {
    //            case .success(let data):
    //                let decoder = JSONDecoder()
    //                do {
    //                    let placesResponse = try decoder.decode(PlacesResponse.self, from: data)
    //                    FirebaseManager.shared.create(in: .places, data: placesResponse)
    //                    FFSManager.shared.addBars(placeResponse: placesResponse.results)
    //                } catch {
    //                    print("Decoding error: \(error)")
    //                }
    //            case .failure(let error):
    //                print("Error fetching data: \(error)")
    //            }
    //        }
    //    }
    
    func sendApiRequest(with nextPageToken: String? = nil) {
        let location  = "25.03028805128867,121.53062812349258"
//        let location = "25.05294070102404,121.52033823497314"
//        let location = "25.04190719631412,121.54378190819422"
//        let location = "25.04193379440791,121.56655051965397"
//        let location = "25.018137469662367,121.53977925830978"
//        let location = "25.036338538165083,121.5198596729418"
//        let location = "25.04989055391903,121.51036693875808"
//        let location = "25.033766771602156,121.50036622630114"
        let radius = 50000
        let type = "bar"
        let language = "zh-TW"
        
        var api = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(location)&radius=\(radius)&language=\(language)&type=\(type)&key=\(GMSPlacesAPIKey)"
        
        if let nextPageToken = nextPageToken {
            api += "&pagetoken=\(nextPageToken)"
        }
        
        AF.request(api, method: .get, encoding: URLEncoding.default)
            .responseDecodable(of: PlacesResponse.self) { [weak self] response in
                
                var places: [Place] = []
                
                switch response.result {
                case .success(let result):
                    places = result.results
                    for place in places {
                        FirebaseManager.shared.create(in: .googlePlaces, data: place)
                    }
                    if let nextPageToken = result.nextPageToken {
                        // Request the next page if there is a next page token
                        self?.sendApiRequest(with: nextPageToken)
                    }
                case .failure:
                    print(response.error!)
                }
            }
    }
}
