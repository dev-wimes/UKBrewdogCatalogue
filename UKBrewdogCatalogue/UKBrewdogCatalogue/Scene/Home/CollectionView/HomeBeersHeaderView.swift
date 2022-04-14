//
//  HomeBeersHeaderView.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/12.
//

import UIKit

final class HomeBeersHeaderView: UICollectionReusableView {
  static let ID: String = "HomeBeersHeaderView"
  
  private let title = UILabel()
  private let footerLine = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.footerLine.backgroundColor = .black
    
    self.setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func configure(title: String) {
    self.title.text = title
  }
  
  private func setupViews() {
    self.addSubview(self.title)
    self.addSubview(self.footerLine)
    
    self.title.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    
    self.footerLine.snp.makeConstraints { make in
      make.height.equalTo(1)
      make.width.bottom.centerX.equalToSuperview()
    }
  }
}
