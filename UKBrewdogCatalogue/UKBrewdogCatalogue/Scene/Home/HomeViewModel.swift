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
  
  // 변하면 안되는 값들은 stream으로 선언하는 것 보다는 let 으로 선언해서 Observable.just로 스트림에 넣는 것이 편하다.
  private let perPage: Int = 25
  
  private let beersRepository: BeersRepository
  private let beersSectionRelay: BehaviorRelay<[BeersSectionModel]> = .init(value: [])
  private let currentPageRelay: BehaviorRelay<Int> = .init(value: 1)
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
    
    let shouldRequestStream = Observable.merge(
      input.loadCellsTrigger.asObservable(),
      input.viewDidLoadTrigger.map{ LoadAction.load }.asObservable()
    )

    let requestStream = shouldRequestStream
      .withLatestFrom(self.currentPageRelay, resultSelector: { action, currentPage -> (action: LoadAction, nextPage: Int) in
        switch action {
        case .load, .refresh:
          return (action: action, nextPage: 1)
        case .loadMore:
          return (action: action, nextPage: currentPage + 1)
        }
      })
      .withLatestFrom(Observable.just(self.perPage), resultSelector: { value, perPage -> (nextPage: Int, perPage: Int) in
        return (nextPage: value.nextPage, perPage: perPage)
      })
      .withUnretained(self)
      .flatMapLatest { owner, value -> Observable<Beers> in
        return owner.getBeers(page: value.nextPage, perPage: value.perPage)
      }
    
    let beersStream = requestStream
      .withLatestFrom(shouldRequestStream) { items, action in
        (action: action, items: items)
      }
      .withLatestFrom(self.beersRelay) { [weak self] param, beers -> Observable<Beers> in
        guard let self = self else { return .empty() }
        switch param.action {
        case .refresh, .load:
          self.currentPageRelay.accept(1)
          return .just(param.items)
        case .loadMore:
          self.currentPageRelay.accept(self.currentPageRelay.value + 1)
          var oldValue = beers
          oldValue += param.items
          return .just(oldValue)
        }
      }
      .flatMapLatest{ $0 }
      .share()
    
    beersStream
      .bind(to: self.beersRelay)
      .disposed(by: self.disposeBag)
    
    beersStream
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
  private func getBeers(page: Int, perPage: Int) -> Observable<Beers> {
    return self.beersRepository.fetchBeers(page: page, perPage: perPage)
      .flatMap { beers -> Observable<Beers> in
        beers.isEmpty ? .empty() : .just(beers)
      }
      .catch({ error in
        return .empty()
      })
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
