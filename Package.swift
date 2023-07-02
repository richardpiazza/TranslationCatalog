// swift-tools-version:5.6
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
        .watchOS(.v8)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "TranslationCatalog",
            targets: ["TranslationCatalog"]
        ),
        .library(
            name: "TranslationCatalogSQLite",
            targets: ["TranslationCatalogSQLite"]
        ),
        .library(
            name: "TranslationCatalogFilesystem",
            targets: ["TranslationCatalogFilesystem"]
        ),
        .executable(
            name: "localizer",
            targets: ["localizer"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/richardpiazza/LocaleSupport.git", .upToNextMajor(from: "0.4.3")),
        .package(url: "https://github.com/richardpiazza/Statement.git", .upToNextMajor(from: "0.7.1")),
        .package(url: "https://github.com/richardpiazza/Perfect-SQLite.git", .upToNextMajor(from: "5.1.1")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", .upToNextMajor(from: "0.15.0")),
        .package(url: "https://github.com/JohnSundell/Plot.git", .upToNextMajor(from: "0.11.0")),
        .package(url: "https://github.com/alexisakers/HTMLString.git", .upToNextMajor(from: "6.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "TranslationCatalog",
            dependencies: ["LocaleSupport"]
        ),
        .target(
            name: "TranslationCatalogSQLite",
            dependencies: [
                "LocaleSupport",
                "TranslationCatalog",
                "Statement",
                .product(name: "StatementSQLite", package: "Statement"),
                .product(name: "PerfectSQLite", package: "Perfect-SQLite")
            ]
        ),
        .target(
            name: "TranslationCatalogFilesystem",
            dependencies: [
                "LocaleSupport",
                "TranslationCatalog",
            ]
        ),
        .executableTarget(
            name: "localizer",
            dependencies: [
                "LocaleSupport",
                "TranslationCatalog",
                "TranslationCatalogSQLite",
                "TranslationCatalogFilesystem",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "XMLCoder",
                "Plot",
                "HTMLString",
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
                "LocaleSupport",
                "TranslationCatalog",
                "TranslationCatalogFilesystem",
                "TranslationCatalogSQLite",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
