// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "ProxyModule",
  platforms: [.iOS(.v12)],
  products: [
    .library(
      name: "ProxyModule",
      targets: ["ProxyModule"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.5.0")),
    .package(name: "Moya", url: "https://github.com/Moya/Moya.git", .exact("15.0.0")),
  ],
  targets: [
    .target(
      name: "ProxyModule",
      dependencies: [
        .product(name: "RxSwift", package: "RxSwift"),
        .product(name: "RxCocoa", package: "RxSwift"),
        .product(name: "RxRelay", package: "RxSwift"),
        .product(name: "RxMoya", package: "Moya"),
      ]),
    .testTarget(
      name: "ProxyModuleTests",
      dependencies: ["ProxyModule"]),
  ]
)
