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
  private let beerImageView = UIImageView()
  private let infoView = UIView()
  private let numberLabel = UILabel()
  private let titleLabel = UILabel()
  private let foodPairingLabel = UILabel()
  private let descriptionLabel = UILabel()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.numberLabel.font = .systemFont(ofSize: 10)
    
    self.titleLabel.numberOfLines = 0
    self.titleLabel.font = .systemFont(ofSize: 12)
    
    self.setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  func configure(
    imageURL: String?,
    number: Int?,
    title: String?,
    foodPairing: [String]?,
    description: String?
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
    
    self.numberLabel.text = "\(number)"
    self.titleLabel.text = title
    self.foodPairingLabel.text = foodPairing?.joined(separator: ", ")
    self.descriptionLabel.text = description
  }
  
  func didSelectCell() {
    print("@@ ", #function)
//    self.contentView.subviews.forEach { $0.constraints.forEach { $0.isActive = false } }
    self.beerImageView.constraints.forEach { $0.isActive = false }
  
    self.beerImageView.snp.makeConstraints { make in
      make.width.height.equalTo(100)
      make.top.equalToSuperview().offset(5)
      make.leading.equalToSuperview()
    }

//    self.infoView.snp.makeConstraints { make in
//      make.top.equalTo(self.beerImageView)
//      make.leading.equalTo(self.beerImageView.snp.trailing).offset(5)
//      make.trailing.equalToSuperview().offset(-5)
//      make.bottom.equalToSuperview()
//    }
//
//    self.numberLabel.snp.makeConstraints { make in
//      make.top.leading.equalToSuperview()
//    }
//
//    self.titleLabel.snp.makeConstraints { make in
//      make.top.equalTo(self.numberLabel.snp.bottom).offset(5)
//      make.bottom.equalToSuperview().offset(-10)
//      make.leading.trailing.equalToSuperview()
//    }
    
    self.foodPairingLabel.isHidden = false
    self.descriptionLabel.isHidden = false
  }
  
  private func setupViews() {
//    self.contentView.addSubview(self.beerImageView)
//    self.contentView.addSubview(self.numberLabel)
//    self.contentView.addSubview(self.titleLabel)
//
//    self.beerImageView.snp.makeConstraints { make in
//      make.width.height.equalTo(50)
//      make.leading.centerY.equalToSuperview()
//    }
//
//    self.numberLabel.snp.makeConstraints { make in
//      make.top.equalToSuperview().offset(5)
//      make.leading.equalTo(self.beerImageView.snp.trailing).offset(5)
//    }
//
//    self.titleLabel.snp.makeConstraints { make in
//      make.top.equalTo(self.numberLabel.snp.bottom).offset(5)
//      make.bottom.equalToSuperview().offset(-10)
//      make.leading.equalTo(self.beerImageView.snp.trailing).offset(5)
//      make.trailing.equalToSuperview().offset(-5)
//    }
    
    self.contentView.addSubview(self.beerImageView)
    self.contentView.addSubview(self.infoView)

    self.beerImageView.snp.makeConstraints { make in
      make.width.height.equalTo(50)
      make.top.equalToSuperview().offset(5)
      make.leading.equalToSuperview()
    }

    self.infoView.snp.makeConstraints { make in
      make.top.equalTo(self.beerImageView)
      make.leading.equalTo(self.beerImageView.snp.trailing).offset(5)
      make.trailing.equalToSuperview().offset(-5)
      make.bottom.equalToSuperview()
    }


    self.infoView.addSubview(self.numberLabel)
    self.infoView.addSubview(self.titleLabel)
    self.infoView.addSubview(self.foodPairingLabel)
    self.infoView.addSubview(self.descriptionLabel)

    self.numberLabel.snp.makeConstraints { make in
      make.top.leading.equalToSuperview()
    }

    self.titleLabel.snp.makeConstraints { make in
      make.top.equalTo(self.numberLabel.snp.bottom).offset(5)
      make.leading.trailing.equalToSuperview()
    }
    
    
    self.foodPairingLabel.snp.makeConstraints { make in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview()
    }
    
    self.descriptionLabel.snp.makeConstraints { make in
      make.top.equalTo(self.foodPairingLabel.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview()
      make.bottom.equalToSuperview().offset(-10)
    }
    
    self.foodPairingLabel.isHidden = true
    self.descriptionLabel.isHidden = true
  }
}

extension HomeBeersCell {
  
  // layout object로부터 주어진 크기에 대해 한번 조정할 기회를 준다.
  override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
    super.preferredLayoutAttributesFitting(layoutAttributes)
    layoutIfNeeded()

    // width는 flow layout이 준 값으로 고정시키고 height만 동적으로 변경해준다.

    // systemLayoutSizeFitting는 constraint를 준수하면서 가장 적합한(optimal)한 size를 반환한다.
    // 즉, 아래 코드는 contentView에 있는 constraint를 준수하는 가장 최적의 크기를 받는 것
    let targetSize = self.contentView.systemLayoutSizeFitting(layoutAttributes.size)
    var frame = layoutAttributes.frame
    frame.size.height = ceil(targetSize.height)
    layoutAttributes.frame = frame
    
    return layoutAttributes
  }
  
  override func prepareForReuse() {
    self.beerImageView.image = nil
    self.disposeBag = .init()
    super.prepareForReuse()
  }
}
