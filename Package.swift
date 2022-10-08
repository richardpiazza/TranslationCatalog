// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TranslationCatalog",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v12),
        .tvOS(.v12),
        .watchOS(.v6)
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
        .executable(
            name: "localizer",
            targets: ["localizer"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/richardpiazza/LocaleSupport.git", .upToNextMinor(from: "0.4.1")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", .upToNextMinor(from: "0.11.1")),
        .package(name: "PerfectSQLite", url: "https://github.com/PerfectlySoft/Perfect-SQLite.git", .upToNextMinor(from: "5.0.0")),
        .package(url: "https://github.com/JohnSundell/Plot.git", .upToNextMinor(from: "0.8.0")),
        .package(url: "https://github.com/alexisakers/HTMLString.git", .upToNextMinor(from: "6.0.0")),
        .package(url: "https://github.com/richardpiazza/Statement.git", .upToNextMinor(from: "0.7.1")),
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
                "PerfectSQLite"
            ]
        ),
        .target(
            name: "localizer",
            dependencies: [
                "LocaleSupport",
                "TranslationCatalog",
                "TranslationCatalogSQLite",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "XMLCoder",
                "Plot",
                "HTMLString",
            ]
        ),
        .testTarget(
            name: "LocalizerTests",
            dependencies: ["localizer"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "TranslationCatalogSQLiteTests",
            dependencies: ["LocaleSupport", "TranslationCatalog", "TranslationCatalogSQLite"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
