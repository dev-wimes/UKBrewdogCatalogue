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
  private var beersRelay: BehaviorRelay<Beers> = .init(value: [])
  
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
    
    let shouldRequest = Observable.merge(
      input.loadCellsTrigger.asObservable(),
      input.viewDidLoadTrigger
        .map{ LoadAction.load }.asObservable()
    )

    let request = shouldRequest
      .withUnretained(self)
    // 밑에서 withLatestFrom을 통해 action을 받는게 싫다면 getBeers 호출 할 때 action을 넘기는 방법도 있음.
      .flatMapLatest { owner, action -> Observable<Beers> in
        switch action {
        case .load, .refresh:
          return owner.getBeers(currentPage: 1, perPage: owner.perPage)
        case .loadMore(numberOfItems: let numberOfItems):
          let page = numberOfItems / owner.perPage + 1
          return owner.getBeers(currentPage: page, perPage: owner.perPage)
        }
      }
      .share()
    
    let fetchedBeers = request
      .catch({ error in
        return .empty()
      })
      .withLatestFrom(shouldRequest) { items, action in
        (action: action, items: items)
      }
      .withLatestFrom(self.beersRelay) { param, beers -> Beers in
        switch param.action {
        case .refresh:
          return param.items
        case .load, .loadMore:
          var oldValue = beers
          oldValue += param.items
          return oldValue
        }
      }
    
    fetchedBeers
      .bind(to: self.beersRelay)
      .disposed(by: self.disposeBag)
    
    fetchedBeers
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
    // 이런식으로 beers와 action을 같이 넘기는 방법도 있다.
//      .map { beers in
//        return (beers, action)
//      }
  }
  
  private func convertToBeersSectionModel(beers: Beers) -> [BeersSectionModel] {
    let beersSectionCellModels = beers.map{
      BeersSectionModel.BeersSectionCellModel(
        imageURL: $0.imageURL,
        number: $0.id,
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
