//
//  HomeViewModel.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/11.
//

import Foundation

import RxSwift
import RxRelay
import RxCocoa

final class HomeViewModel {
  private let disposeBag = DisposeBag()
  
  private let beersRepository: BeersRepository
  private var currentPage: Int
  
  struct Input {
    var viewDidLoadTrigger: PublishRelay<Void>
  }
  
  struct Output {
    var fetchedBeers: Driver<[BeersSectionModel]>
  }
  
  init(beersRepository: BeersRepository = BeersRepositoryImpl()) {
    self.beersRepository = beersRepository
    self.currentPage = 1
  }
  
  func transform(input: Input) -> Output {
    let beersRelay: BehaviorRelay<[BeersSectionModel]> = .init(value: [])
    
    input.viewDidLoadTrigger
      .withUnretained(self)
      .subscribe(onNext: { owner, _ in
        owner.getBeers(relay: beersRelay)
      })
      .disposed(by: self.disposeBag)
    
    return Output(fetchedBeers: beersRelay.asDriver())
  }
}

extension HomeViewModel {
  private func getBeers(relay: BehaviorRelay<[BeersSectionModel]>) {
    self.beersRepository.fetchBeers(page: self.currentPage)
      .asObservable()
      .catch { error in
        print("@@ error: ", error)
        return .empty()
      }
      .withUnretained(self)
      .subscribe(onNext: { owner, beers in
        owner.currentPage += 1
        
        let beersSectionCellModels = beers.map{
          BeersSectionModel.BeersSectionCellModel(
            imageURL: $0.imageURL,
            name: $0.name
          )
        }
        
        let sections = [
          BeersSectionModel(
            header: .init(),
            items: beersSectionCellModels
          )
        ]
        
        relay.accept(sections)
      })
      .disposed(by: self.disposeBag)
  }
}
