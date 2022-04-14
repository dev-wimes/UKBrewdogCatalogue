//
//  ImageRepository.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/14.
//

import Foundation
import UIKit

import RxSwift

protocol ImageRepository {
  func loadImage(url: String?) -> Observable<UIImage>
}

final class ImageRepositoryImpl: BaseRepository, ImageRepository {
  enum ImageRepositoryError: Error {
    case wrongURLString(url: String?)
    case dataError
    case imageError
  }
  
  func loadImage(url: String?) -> Observable<UIImage> {
    guard let urlString = url,
          let url = URL(string: urlString)
    else { return .error(ImageRepositoryError.wrongURLString(url: url)) }
    
    return Observable<UIImage>.create { observable in
      let task = URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data = data else {
          observable.onError(ImageRepositoryError.dataError)
          observable.onCompleted()
          return
        }
        
        guard let image = UIImage(data: data) else {
          return observable.onError(ImageRepositoryError.imageError)
        }
        
        observable.onNext(image)
        observable.onCompleted()
      }
      
      task.resume()
      
      return Disposables.create {
        task.cancel()
      }
    }
  }
}
