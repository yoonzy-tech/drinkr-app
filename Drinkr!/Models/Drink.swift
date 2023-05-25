//
//  Drink.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import Foundation

struct CocktailResponse: Codable {
    let drinks: [Drink]
    
    func toDictionary() -> [String: Any]? {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return dictionary
        } catch {
            print("Error converting to dictionary: \(error)")
            return nil
        }
    }
}

struct Drink: Codable {
    let idDrink: String?
    let strDrink: String?
    let strDrinkAlternate: String?
    let strTags: String?
    let strVideo: String?
    let strCategory: String?
    let strIBA: String?
    let strAlcoholic: String?
    let strGlass: String?
    let strInstructions: String
    let strInstructionsES: String?
    let strInstructionsDE: String?
    let strInstructionsFR: String?
    let strInstructionsIT: String?
    let strInstructionsZHHANS: String?
    let strInstructionsZHHANT: String?
    let strDrinkThumb: String?
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strImageSource: String
    let strImageAttribution: String?
    let strCreativeCommonsConfirmed: String?
    let dateModified: String?
    
    enum CodingKeys: String, CodingKey {
        // Add any custom coding keys here if needed
        case idDrink, strDrink, strDrinkAlternate, strTags, strVideo, strCategory, strIBA
        case strAlcoholic, strGlass, strInstructions, strInstructionsES, strInstructionsDE
        case strInstructionsFR, strInstructionsIT
        case strInstructionsZHHANS = "strInstructionsZH_HANS"
        case strInstructionsZHHANT = "strInstructionsZH_HANT"
        case strDrinkThumb, strIngredient1, strIngredient2, strIngredient3, strIngredient4
        case strIngredient5, strIngredient6, strIngredient7, strIngredient8, strIngredient9
        case strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14
        case strIngredient15, strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
        case strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10, strMeasure11
        case strMeasure12, strMeasure13, strMeasure14, strMeasure15, strImageSource
        case strImageAttribution, strCreativeCommonsConfirmed, dateModified
    }
}

extension Drink {
    func toDictionary() -> [String: Any] {
        let mirror = Mirror(reflecting: self)
        var dictionary: [String: Any] = [:]

        for (label, value) in mirror.children {
            if let label = label {
                dictionary[label] = value
            }
        }

        return dictionary
    }
}
