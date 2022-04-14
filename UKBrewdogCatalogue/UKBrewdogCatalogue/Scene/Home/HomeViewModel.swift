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
  private let beersSectionRelay: BehaviorRelay<[BeersSectionModel]> = .init(value: [])
  private var currentPageRelay: BehaviorRelay<Int> = .init(value: 1)
  private let perPage: Int = 25
  private var beers: Beers = []
  
  struct Input {
    var viewDidLoadTrigger: PublishRelay<Void>
    var loadCellsTrigger: PublishRelay<LoadAction>
  }
  
  struct Output {
    var fetchedBeers: Driver<[BeersSectionModel]>
  }
  
  enum LoadAction {
    case load
    case loadMore(numberOfItems: Int)
    case refresh
  }
  
  init(beersRepository: BeersRepository = BeersRepositoryImpl()) {
    self.beersRepository = beersRepository
  }
  
  func transform(input: Input) -> Output {
    
    input.loadCellsTrigger
      .withUnretained(self)
      .flatMapLatest { owner, action -> Observable<Beers> in
        switch action {
        case .load, .refresh:
          return owner.getBeers(currentPage: 1, perPage: owner.perPage)
        case .loadMore(numberOfItems: let numberOfItems):
          let page = numberOfItems / owner.perPage + 1
          return owner.getBeers(currentPage: page, perPage: owner.perPage)
        }
      }
      .withLatestFrom(input.loadCellsTrigger) { items, action in
        (action: action, items: items)
      }
      .withUnretained(self)
      .map { owner, param -> Beers in
        switch param.action {
        case .refresh:
          owner.beers = param.items
        case .load, .loadMore:
          owner.beers += param.items
        }
        return owner.beers
      }
      .map(self.convertToBeersSectionModel(beers:))
      .withUnretained(self)
      .subscribe(onNext: { owner, beers in
        owner.beersSectionRelay.accept(beers)
      })
      .disposed(by: self.disposeBag)
    
    return Output(fetchedBeers: self.beersSectionRelay.asDriver())
  }
}

extension HomeViewModel {
  private func getBeers(currentPage: Int, perPage: Int) -> Observable<Beers> {
    self.beersRepository.fetchBeers(page: currentPage, perPage: perPage)
      .catch { error in .empty() }
  }
  
  private func convertToBeersSectionModel(beers: Beers) -> [BeersSectionModel] {
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
    
    return sections
  }
}
