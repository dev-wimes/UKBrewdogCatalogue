//
//  HomeViewController+RxDataSources.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/19.
//

import Foundation
import UIKit

import RxDataSources

extension HomeViewController {
  static var dataSource: RxCollectionViewSectionedReloadDataSource<BeersSectionModel> {
    let configureCell: (
      CollectionViewSectionedDataSource<BeersSectionModel>,
      UICollectionView,
      IndexPath,
      BeersSectionModel.Item
    ) -> UICollectionViewCell = { dataSource, collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeBeersCell.ID, for: indexPath) as! HomeBeersCell
      cell.configure(
        imageURL: dataSource[indexPath].imageURL,
        number: dataSource[indexPath].number,
        title: dataSource[indexPath].name,
        foodPairing: dataSource[indexPath].foodPairing,
        description: dataSource[indexPath].description
      )
      return cell
    }
    
    let supplementrayView: (
      CollectionViewSectionedDataSource<BeersSectionModel>,
      UICollectionView,
      String,
      IndexPath
    ) -> UICollectionReusableView = { dataSource, collectionView, kind, indexPath in
      guard let title = dataSource.sectionModels.first?.header.title else { return UICollectionReusableView()}
      let view = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind,
        withReuseIdentifier: HomeBeersHeaderView.ID,
        for: indexPath
      ) as! HomeBeersHeaderView
      view.configure(title: title)
      return view
    }
    
    let dataSource = RxCollectionViewSectionedReloadDataSource<BeersSectionModel>.init(
      configureCell: configureCell,
      configureSupplementaryView: supplementrayView
    )
    
    return dataSource
  }
}
