//
//  Drink.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/5/25.
//

import Foundation

struct CocktailResponse: Codable {
    let drinks: [Drink]
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
    let strInstructions: String?
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
    let strImageSource: String?
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
    
    init?(data: [String: Any]) {
        self.idDrink = data["idDrink"] as? String
        self.strDrink = data["strDrink"] as? String
        self.strDrinkAlternate = data["strDrinkAlternate"] as? String
        self.strTags = data["strTags"] as? String
        self.strVideo = data["strVideo"] as? String
        self.strCategory = data["strCategory"] as? String
        self.strIBA = data["strIBA"] as? String
        self.strAlcoholic = data["strAlcoholic"] as? String
        self.strGlass = data["strGlass"] as? String
        self.strInstructions = data["strInstructions"] as? String
        self.strInstructionsES = data["strInstructionsES"] as? String
        self.strInstructionsDE = data["strInstructionsDE"] as? String
        self.strInstructionsFR = data["strInstructionsFR"] as? String
        self.strInstructionsIT = data["strInstructionsIT"] as? String
        self.strInstructionsZHHANS = data["strInstructionsZH-HANS"] as? String
        self.strInstructionsZHHANT = data["strInstructionsZH-HANT"] as? String
        self.strDrinkThumb = data["strDrinkThumb"] as? String
        self.strIngredient1 = data["strIngredient1"] as? String
        self.strIngredient2 = data["strIngredient2"] as? String
        self.strIngredient3 = data["strIngredient3"] as? String
        self.strIngredient4 = data["strIngredient4"] as? String
        self.strIngredient5 = data["strIngredient5"] as? String
        self.strIngredient6 = data["strIngredient6"] as? String
        self.strIngredient7 = data["strIngredient7"] as? String
        self.strIngredient8 = data["strIngredient8"] as? String
        self.strIngredient9 = data["strIngredient9"] as? String
        self.strIngredient10 = data["strIngredient10"] as? String
        self.strIngredient11 = data["strIngredient11"] as? String
        self.strIngredient12 = data["strIngredient12"] as? String
        self.strIngredient13 = data["strIngredient13"] as? String
        self.strIngredient14 = data["strIngredient14"] as? String
        self.strIngredient15 = data["strIngredient15"] as? String
        self.strMeasure1 = data["strMeasure1"] as? String
        self.strMeasure2 = data["strMeasure2"] as? String
        self.strMeasure3 = data["strMeasure3"] as? String
        self.strMeasure4 = data["strMeasure4"] as? String
        self.strMeasure5 = data["strMeasure5"] as? String
        self.strMeasure6 = data["strMeasure6"] as? String
        self.strMeasure7 = data["strMeasure7"] as? String
        self.strMeasure8 = data["strMeasure8"] as? String
        self.strMeasure9 = data["strMeasure9"] as? String
        self.strMeasure10 = data["strMeasure10"] as? String
        self.strMeasure11 = data["strMeasure11"] as? String
        self.strMeasure12 = data["strMeasure12"] as? String
        self.strMeasure13 = data["strMeasure13"] as? String
        self.strMeasure14 = data["strMeasure14"] as? String
        self.strMeasure15 = data["strMeasure15"] as? String
        self.strImageSource = data["strImageSource"] as? String
        self.strImageAttribution = data["strImageAttribution"] as? String
        self.strCreativeCommonsConfirmed = data["strCreativeCommonsConfirmed"] as? String
        self.dateModified = data["dateModified"] as? String

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
