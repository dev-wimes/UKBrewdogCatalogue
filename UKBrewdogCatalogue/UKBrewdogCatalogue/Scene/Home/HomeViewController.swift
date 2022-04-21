//
//  HomeViewController.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/10.
//

import UIKit

import RxSwift
import RxRelay
import RxDataSources

final class HomeViewController: UIViewController {
  private let disposeBag = DisposeBag()
  
  private let viewModel = HomeViewModel()
  private let viewDidLoadTrigger = PublishRelay<Void>()
  private let loadCellsTrigger = PublishRelay<HomeViewModel.LoadAction>()
  
  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    return collectionView
  }()
  
  // @@todo base vc 만들어서 viewDidLoad를 매번 선언하지 않는 방향으로
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setupViews()
    self.bind()
    
    self.viewDidLoadTrigger.accept(())
  }
  
  private func setupViews() {
    self.view.addSubview(self.collectionView)
    self.collectionView.register(
      HomeBeersHeaderView.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: HomeBeersHeaderView.ID
    )
    self.collectionView.register(HomeBeersCell.self, forCellWithReuseIdentifier: HomeBeersCell.ID)
    
    self.collectionView.rx
      .setDelegate(self)
      .disposed(by: self.disposeBag)
    
    self.collectionView.snp.makeConstraints { make in
      make.top.bottom.leading.trailing.equalToSuperview()
    }
  }
  
  private func bind() {
    let output = self.viewModel
      .transform(input: .init(viewDidLoadTrigger: self.viewDidLoadTrigger, loadCellsTrigger: self.loadCellsTrigger))
    
    output.fetchedBeers
      .drive(self.collectionView.rx.items(dataSource: HomeViewController.dataSource))
      .disposed(by: self.disposeBag)
    
    self.collectionView.rx.willDisplayCell
      .throttle(.microseconds(400), scheduler: MainScheduler.asyncInstance)
      .withUnretained(self)
      .subscribe(onNext: { owner, rxInfo in
        let numberOfItems = owner.collectionView.numberOfItems(inSection: rxInfo.at.section)
        if rxInfo.at.row == numberOfItems - 1 {
          owner.loadCellsTrigger.accept(.loadMore(numberOfItems: numberOfItems))
        }
      })
      .disposed(by: self.disposeBag)
  }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: self.view.frame.width, height: 50)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: self.view.frame.width / 2 - 10, height: 50)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 5.0
  }
}
