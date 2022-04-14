//
//  BeerMethod.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/14.
//

import Foundation

struct BeerMethod: Codable {
    let mashTemp: [MashTemp]
    let fermentation: Fermentation
    let twist: String?
    
    enum CodingKeys: String, CodingKey {
        case mashTemp = "mash_temp"
        case fermentation, twist
    }
}

struct MashTemp: Codable {
    let temp: Temp
    let duration: Int?
}

struct Temp: Codable {
    let value: Int
    let unit: String
}

struct Fermentation: Codable {
    let temp: Temp
}
