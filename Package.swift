// swift-tools-version: 5.9
//
//  Package.swift
//  KitoOnboarding
//
//  Created by Wycliff on 9/18/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//


import PackageDescription

let package = Package(
    name: "KitoOnboarding",
    platforms: [.iOS(.v17)],
    products: [.library(name: "KitoOnboarding", targets: ["KitoOnboarding"])],
    dependencies: [
        .package(url: "https://github.com/WykSofts-Inc/KitoCore.git", from: "1.0.0"),
    ],
    targets: [
        .target(name: "KitoOnboarding", dependencies: [.product(name: "KitoCore", package: "KitoCore")]),
        .testTarget(name: "KitoOnboardingTests", dependencies: ["KitoOnboarding"]),
    ]
)
