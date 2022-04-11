//
//  HomeViewController.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/10.
//

import UIKit

import RxSwift

class HomeViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .red
    
    let test_repository: BeersRepository = BeersRepositoryImpl()
    test_repository.fetchBeers(page: 1, perPage: 20)
      .subscribe { beers in
        print(beers)
      } onFailure: { error in
        print(error)
      }
      .disposed(by: self.disposeBag)
  }


}

