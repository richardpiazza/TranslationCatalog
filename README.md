# TranslationCatalog

Swift toolkit for managing app localization &amp; internationalization.

<p>
  <img src="https://github.com/richardpiazza/TranslationCatalog/workflows/Swift/badge.svg?branch=main" />
  <img src="https://img.shields.io/badge/Swift-5.6-orange.svg" />
  <a href="https://twitter.com/richardpiazza">
    <img src="https://img.shields.io/badge/twitter-@richardpiazza-blue.svg?style=flat" alt="Twitter: @richardpiazza" />
  </a>
</p>

## Usage

**TranslationCatalog** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, add it as 
a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/richardpiazza/TranslationCatalog.git", .upToNextMinor(from: "0.1.0"))
    ],
    ...
)
```

Then import the **TranslationCatalog** packages wherever you'd like to use it:

```swift
import TranslationCatalog
```

## Targets

This toolkit is comprised of several components:

### TranslationCatalog

Entity definitions for a lightweight catalog that can persist and retrieve translations.

### TranslationCatalogFilesystem

A cross-platform implementation of the _Translation Catalog_ that uses directories and JSON documents.

### TranslationCatalogSQLite

A cross-platform implementation of the _Translation Catalog_ that is backed by a SQLite store.

### `localizer`

A swift command line that can interact with a catalog along with importing, exporting, and documenting localizations.

## Helpful Information

* [Apple String Format Specifiers](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFStrings/formatSpecifiers.html#//apple_ref/doc/uid/TP40004265)
* [IEEE printf Specification](https://pubs.opengroup.org/onlinepubs/009695399/functions/printf.html)

## Contribution

Contributions to **LocaleSupport** are welcomed and encouraged!
