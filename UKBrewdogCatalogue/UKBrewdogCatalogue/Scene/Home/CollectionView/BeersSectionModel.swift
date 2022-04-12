//
//  BeersSectionModel.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/12.
//

import RxDataSources

struct BeersSectionModel {
  typealias Item = BeersSectionCellModel
  
  var header: BeersSectionHeaderModel
  var items: [Item]
}

extension BeersSectionModel: SectionModelType {
  init(original: BeersSectionModel, items: [Item]) {
    self = original
    self.items = items
  }
  
  struct BeersSectionHeaderModel {
    let title: String = "Brewdog's Beers"
  }

  struct BeersSectionCellModel {
    let imageURL: String
    let name: String
  }
}

