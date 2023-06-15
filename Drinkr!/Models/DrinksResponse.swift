//
//  DCocktails.swift
//  Drinkr!
//
//  Created by Ruby Chew on 2023/6/4.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct FavDrink: Codable {
    let idDrink: String
    let addedTime: Timestamp?
}

struct DrinksResponse: Codable {
    let drinks: [Drink]
}

struct Drink: Codable {
    @DocumentID var id: String?
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
    let strInstructionsCHTrad: String?
    let strInstructionsCHSimp: String?
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
        case idDrink, strDrink, strDrinkAlternate, strTags, strVideo, strCategory, strIBA, strAlcoholic, strGlass
        case strInstructions, strInstructionsES, strInstructionsDE, strInstructionsFR, strInstructionsIT
        case strInstructionsCHTrad = "strInstructionsZH_HANS"
        case strInstructionsCHSimp = "strInstructionsZH_HANT"
        case strDrinkThumb
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5
        case strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10
        case strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5
        case strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10
        case strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15
        case strImageSource, strImageAttribution
        case strCreativeCommonsConfirmed, dateModified
    }
    
    func getIngredients() -> String {
        var ingredients: String = ""
        
        let codingKeys = Drink.CodingKeys.self
        
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            if let label = child.label,
               let codingKey = codingKeys.init(rawValue: label),
               codingKey.rawValue.starts(with: "strIngredient"),
               let ingredient = child.value as? String, !ingredient.isEmpty {
                
                ingredients += "\(ingredient), "
            }
        }
        
        let endIndex = ingredients.index(ingredients.endIndex, offsetBy: -3)
        
        return String(ingredients[ingredients.startIndex...endIndex])
    }

    mutating func getMeasureIngredients() -> String {
        var ingredients: String = ""
        
        let codingKeys = Drink.CodingKeys.self
        
        let mirror = Mirror(reflecting: self)
        
        for child in mirror.children {
            if let label = child.label,
               let codingKey = codingKeys.init(rawValue: label),
               codingKey.rawValue.starts(with: "strIngredient"),
               let ingredient = child.value as? String, !ingredient.isEmpty {
                
                let measureKey = codingKeys.init(rawValue: "strMeasure" + label.suffix(1))
                let measure = mirror.children.first(where: { $0.label == measureKey?.stringValue })?.value as? String
                
                if let measure = measure, !measure.isEmpty {
                    ingredients += "\(measure) \(ingredient)\n"
                } else {
                    ingredients += "\(ingredient)\n"
                }
            }
        }
        
        let endIndex = ingredients.index(ingredients.endIndex, offsetBy: -2)
        
        return String(ingredients[ingredients.startIndex...endIndex])
    }
}
