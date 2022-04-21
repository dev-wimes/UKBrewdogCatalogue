//
//  HomeCollectionViewFlowLayout.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/19.
//

import UIKit

final class HomeCollectionViewFlowLayout: UICollectionViewFlowLayout {
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let layoutAttributeObjects = super.layoutAttributesForElements(in: rect)
    
    layoutAttributeObjects?.forEach { layoutAttribute in
      if layoutAttribute.representedElementCategory == .cell {
        if let newframe = layoutAttributesForItem(at: layoutAttribute.indexPath)?.frame {
          layoutAttribute.frame = newframe
        }
      }
    }
    
    return layoutAttributeObjects
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let collectionView = collectionView else { return nil }
    guard let layoutAttributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
    
    layoutAttributes.frame.size.width = collectionView.safeAreaLayoutGuide.layoutFrame.width
    
    return layoutAttributes
  }
}
