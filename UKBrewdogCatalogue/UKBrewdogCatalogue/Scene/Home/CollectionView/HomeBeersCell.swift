//
//  HomeBeersCell.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/12.
//

import UIKit

import SnapKit
import RxSwift

final class HomeBeersCell: UICollectionViewCell {
  static let ID: String = "HomeBeersCell"
  
  private var disposeBag = DisposeBag()
  private let imageRepository: ImageRepository = ImageRepositoryImpl()
  private let number = UILabel()
  private let title = UILabel()
  private let beerImageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.number.font = .systemFont(ofSize: 10)
    
    self.title.numberOfLines = 0
    self.title.font = .systemFont(ofSize: 12)
    
    self.setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func configure(
    imageURL: String?,
    number: Int?,
    title: String?
  ) {
    self.imageRepository.loadImage(url: imageURL)
      .observe(on: MainScheduler.asyncInstance)
      .catch { error in
//        print("@@ error", error)
        
        return Observable.just(UIImage(named: "drunk.gif")!)
      }
      .withUnretained(self)
      .subscribe(onNext: { owner, image in
        owner.beerImageView.image = image
        owner.beerImageView.contentMode = .scaleAspectFit
      })
      .disposed(by: self.disposeBag)
    
    guard let number = number else { return }
    
    self.number.text = "\(number)"
    self.title.text = title
  }
  
  private func setupViews() {
    self.contentView.addSubview(self.beerImageView)
    self.contentView.addSubview(self.number)
    self.contentView.addSubview(self.title)
    
    self.beerImageView.snp.makeConstraints { make in
      make.width.height.equalTo(50)
      make.leading.centerY.equalToSuperview()
    }
    
    self.number.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(5)
      make.leading.equalTo(self.beerImageView.snp.trailing).offset(5)
    }
    
    self.title.snp.makeConstraints { make in
//      make.centerY.equalToSuperview()
      make.top.equalTo(self.number.snp.bottom).offset(5)
      make.leading.equalTo(self.beerImageView.snp.trailing).offset(5)
      make.trailing.equalToSuperview().offset(-5)
    }
  }
}

extension HomeBeersCell {
  
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    super.preferredLayoutAttributesFitting(layoutAttributes)
    
    let targetSize = CGSize(width: layoutAttributes.frame.width, height: 0)
    
    layoutAttributes.frame.size = self.contentView.systemLayoutSizeFitting(
      targetSize,
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )
    
    return layoutAttributes
  }
  
  override func prepareForReuse() {
    self.beerImageView.image = nil
    self.disposeBag = .init()
    super.prepareForReuse()
  }
}
