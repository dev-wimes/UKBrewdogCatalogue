//
//  Beers.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/11.
//

import Foundation

typealias Beers = [Beer]

// MARK: - BeerElement
struct Beer: Codable {
  let id: Int
  let name, tagline, firstBrewed, beerDescription: String
  let imageURL: String
  let abv: Double
  let ibu: Double?
  let targetFg: Int
  let targetOg: Double
  let ebc: Int?
  let srm, ph: Double?
  let attenuationLevel: Double
  let volume, boilVolume: BoilVolume
  let method: Method
  let ingredients: Ingredients
  let foodPairing: [String]
  let brewersTips: String
  let contributedBy: ContributedBy
  
  enum CodingKeys: String, CodingKey {
    case id, name, tagline
    case firstBrewed = "first_brewed"
    case beerDescription = "description"
    case imageURL = "image_url"
    case abv, ibu
    case targetFg = "target_fg"
    case targetOg = "target_og"
    case ebc, srm, ph
    case attenuationLevel = "attenuation_level"
    case volume
    case boilVolume = "boil_volume"
    case method, ingredients
    case foodPairing = "food_pairing"
    case brewersTips = "brewers_tips"
    case contributedBy = "contributed_by"
  }
}

extension Beer {
  // MARK: - BoilVolume
  struct BoilVolume: Codable {
    let value: Double
    let unit: Unit
  }
  
  // MARK: - Method
  struct Method: Codable {
    let mashTemp: [MashTemp]
    let fermentation: Fermentation
    let twist: String?
    
    enum CodingKeys: String, CodingKey {
      case mashTemp = "mash_temp"
      case fermentation, twist
    }
  }
  
  // MARK: - Ingredients
  struct Ingredients: Codable {
    let malt: [Malt]
    let hops: [Hop]
    let yeast: String
  }
  
  enum ContributedBy: String, Codable {
    case aliSkinnerAliSkinner = "Ali Skinner <AliSkinner>"
    case samMasonSamjbmason = "Sam Mason <samjbmason>"
  }
}


extension Beer.BoilVolume{
  enum Unit: String, Codable {
    case celsius = "celsius"
    case grams = "grams"
    case kilograms = "kilograms"
    case litres = "litres"
  }
}

extension Beer.Method {
  // MARK: - MashTemp
  struct MashTemp: Codable {
    let temp: Beer.BoilVolume
    let duration: Int?
  }
  
  // MARK: - Fermentation
  struct Fermentation: Codable {
    let temp: Beer.BoilVolume
  }
}

extension Beer.Ingredients {
  // MARK: - Malt
  struct Malt: Codable {
    let name: String
    let amount: Beer.BoilVolume
  }

  // MARK: - Hop
  struct Hop: Codable {
    let name: String
    let amount: Beer.BoilVolume
    let add: Add
    let attribute: Attribute
  }
}

extension Beer.Ingredients.Hop {
  enum Add: String, Codable {
    case dryHop = "dry hop"
    case end = "end"
    case middle = "middle"
    case start = "start"
  }

  enum Attribute: String, Codable {
    case aroma = "aroma"
    case attributeFlavour = "Flavour"
    case bitter = "bitter"
    case flavour = "flavour"
  }
}










