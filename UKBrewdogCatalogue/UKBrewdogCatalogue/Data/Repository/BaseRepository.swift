//
//  BaseRepository.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/11.
//

import Foundation

import RxSwift
import Moya

class BaseRepository {
  let disposeBag = DisposeBag()
  let provider = MoyaProvider<BrewdogCategoryAPI>()
  
  func execute<T: Decodable>(api: BrewdogCategoryAPI) -> Single<T> {
    self.provider.rx.request(api)
      .filterSuccessfulStatusCodes()
      .map(T.self)
  }
}
