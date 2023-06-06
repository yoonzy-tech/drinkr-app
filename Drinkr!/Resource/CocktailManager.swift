//
//  DrinksManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import Foundation
import Alamofire

class CocktailManager {
    
    static let shared = CocktailManager()
    
    private init() {}
    
    let latest = "https://the-cocktail-db.p.rapidapi.com/latest.php"
    let popular = "https://the-cocktail-db.p.rapidapi.com/popular.php"
    
    let headers: HTTPHeaders = [
        "X-RapidAPI-Key": cocktailDBApiKey,
        "X-RapidAPI-Host": "the-cocktail-db.p.rapidapi.com"
    ]
    
    func sendApiRequest(api: String) {
        AF.request(api, method: .get, encoding: URLEncoding.default, headers: headers)
            .responseDecodable(of: DrinksResponse.self) { response in
                
                var cocktails: [Drink] = []
                
                switch response.result {
                case .success(let result):
                    cocktails = result.drinks
                    for cocktail in cocktails {
                        FirebaseManager.shared.create(in: .cocktails, data: cocktail)
                    }
                case .failure:
                    print(response.error!)
                }
            }
    }
    
    func getAllCocktailsFromApi() {
        let params = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                      "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
                      "k", "l", "m", "n", "o", "p", "q", "r", "s", "t",
                      "u", "v", "w", "x", "y", "z"]
        
        for param in params {
            let api = "www.thecocktaildb.com/api/json/v1/1/search.php?f=\(param)"
            AF.request(api, method: .get, encoding: URLEncoding.default, headers: headers)
                .responseDecodable(of: DrinksResponse.self) { response in
                    
                    var cocktails: [Drink] = []
                    
                    switch response.result {
                    case .success(let result):
                        cocktails = result.drinks
                        for cocktail in cocktails {
                            FirebaseManager.shared.create(in: .cocktails, data: cocktail)
                        }
                    case .failure:
                        print(response.error!)
                    }
                }
        }
    }
    
}
