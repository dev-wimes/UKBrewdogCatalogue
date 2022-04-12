//
//  BeersRepository.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/11.
//

import Foundation
import RxSwift

protocol BeersRepository {
  func fetchBeers(page: Int) -> Single<Beers>
}

final class BeersRepositoryImpl: BaseRepository, BeersRepository {
  func fetchBeers(page: Int) -> Single<Beers> {
    let query = BeersQ(page: page)
    
    return self.execute(api: .beers(q: query))
  }
}
