//
//  HomeBeersCell.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/12.
//

import UIKit

import SnapKit

final class HomeBeersCell: UICollectionViewCell {
  static let ID: String = "HomeBeersCell"
  
  private let title = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func configure(title: String) {
    self.title.text = title
  }
  
  private func setupViews() {
    self.contentView.addSubview(self.title)
    
    self.title.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
}
