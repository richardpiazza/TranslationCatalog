// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TranslationCatalog",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v12),
        .macCatalyst(.v15),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TranslationCatalog",
            targets: [
                "TranslationCatalog",
                "TranslationCatalogIO",
                "TranslationCatalogSQLite",
                "TranslationCatalogFilesystem",
            ]
        ),
        .executable(
            name: "localizer",
            targets: ["localizer"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/richardpiazza/LocaleSupport.git", .upToNextMajor(from: "0.6.0")),
        .package(url: "https://github.com/richardpiazza/AsyncPlus.git", .upToNextMinor(from: "0.3.2")),
        .package(url: "https://github.com/richardpiazza/Statement.git", .upToNextMajor(from: "0.8.1")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.5.1")),
        .package(url: "https://github.com/CoreOffice/XMLCoder.git", .upToNextMajor(from: "0.17.1")),
        .package(url: "https://github.com/JohnSundell/Plot.git", .upToNextMajor(from: "0.14.0")),
        .package(url: "https://github.com/alexisakers/HTMLString.git", .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", .upToNextMajor(from: "0.15.4")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TranslationCatalog",
            dependencies: ["LocaleSupport"]
        ),
        .target(
            name: "TranslationCatalogIO",
            dependencies: [
                "TranslationCatalog",
                .product(name: "AsyncPlus", package: "AsyncPlus"),
                .product(name: "XMLCoder", package: "XMLCoder"),
                .product(name: "Plot", package: "Plot"),
                .product(name: "HTMLString", package: "HTMLString"),
            ]
        ),
        .target(
            name: "TranslationCatalogSQLite",
            dependencies: [
                "TranslationCatalog",
                .product(name: "LocaleSupport", package: "LocaleSupport"),
                .product(name: "Statement", package: "Statement"),
                .product(name: "StatementSQLite", package: "Statement"),
                .product(name: "SQLite", package: "SQLite.swift"),
            ]
        ),
        .target(
            name: "TranslationCatalogFilesystem",
            dependencies: [
                "TranslationCatalog",
                .product(name: "LocaleSupport", package: "LocaleSupport"),
            ]
        ),
        .executableTarget(
            name: "localizer",
            dependencies: [
                "LocaleSupport",
                "TranslationCatalog",
                "TranslationCatalogIO",
                "TranslationCatalogSQLite",
                "TranslationCatalogFilesystem",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
            name: "LocalizerTests",
            dependencies: ["localizer"],
            resources: [
                .process("Resources"),
                .copy("StructuredResources"),
            ]
        ),
        .testTarget(
            name: "TranslationCatalogTests",
            dependencies: [
                "TranslationCatalog",
                "TranslationCatalogIO",
                "TranslationCatalogFilesystem",
                "TranslationCatalogSQLite",
                .product(name: "LocaleSupport", package: "LocaleSupport"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
