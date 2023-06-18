//
//  DrinksInfo.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/18.
//

import Foundation

struct DrinksData: Codable {
    var drinks: [DrinkInfo]
}

struct DrinkInfo: Codable {
    var label: String
    var name: String
    var origin: String
    var vol: String
    var type: String
}

class DrinksService {
    static let shared = DrinksService()
    var drinksInfo: [DrinkInfo]
    
    private init() {
        drinksInfo = []
        loadDrinksInfo()
    }
    
    func getDrinkInfo(label: String) -> DrinkInfo? {
        for info in drinksInfo where label == info.label {
            return info
        }
        return nil
    }
    
    func loadDrinksInfo() {
        let drinksInfoFileUrl = Bundle.main.url(forResource: "DrinksInfo", withExtension: "json")!
        
        do {
            let drinksData = try Data(contentsOf: drinksInfoFileUrl)
            let decoder = JSONDecoder()
            let drinks = try decoder.decode(DrinksData.self, from: drinksData)
            drinksInfo = drinks.drinks
        } catch {
            print("error loading whiskies info")
        }
    }
}
