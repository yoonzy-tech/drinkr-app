//
//  DrinksManager.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import Foundation
import Alamofire

class DrinksManager {
    
    static let shared = DrinksManager()
    
    private init() {}
    
    var drinks: [Drink] = []
    
    func readLatestCocktails() {
        let api = "https://the-cocktail-db.p.rapidapi.com/latest.php"
        let headers: HTTPHeaders = [
            "X-RapidAPI-Key": cocktailDBApiKey,
            "X-RapidAPI-Host": "the-cocktail-db.p.rapidapi.com"
        ]
        
        AF.request(api, method: .get, encoding: URLEncoding.default, headers: headers)
            .responseDecodable(of: CocktailResponse.self) { response in
            
            switch response.result {
            case .success(let result):
                let drinkList = result.drinks
                FFSManager.shared.addCocktails(drinkList: drinkList)
            case .failure:
                print(response.error!)
            }
        }
        
    }
}
