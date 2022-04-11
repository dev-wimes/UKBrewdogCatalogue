//
//  BrewdogCategoryAPI.swift
//  UKBrewdogCatalogue
//
//  Created by Wimes on 2022/04/11.
//

import Foundation

import Moya
import RxMoya

enum BrewdogCategoryAPI {
  case beers(q: BeersQ)
}

extension BrewdogCategoryAPI: TargetType {
  var baseURL: URL {
    return URL(string: "https://api.punkapi.com/v2")!
  }
  
  var path: String {
    switch self {
    case .beers:
      return "/beers"
    }
  }
  
  var method: Moya.Method {
    switch self {
    default:
      return .get
    }
  }
  
  var parameter: [String: Any]? {
    switch self {
    case .beers(let q):
      return ["page": q.page, "perPage": q.perPage]
    }
  }
  
  var headers: [String : String]? {
    let defaultHeader = ["Content-Type": "application/json"]
    
    switch self {
    default:
      return defaultHeader
    }
  }
  
  var task: Task {
    let parameter = self.parameter ?? [:]
    
    switch self.method{
    case .get:
      return .requestParameters(parameters: parameter, encoding: URLEncoding.default)
    default:
      return .requestParameters(parameters: parameter, encoding: JSONEncoding.default)
    }
  }
}
