# TranslationCatalog

Swift toolkit for managing app localization &amp; internationalization.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FTranslationCatalog%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/richardpiazza/TranslationCatalog)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Frichardpiazza%2FTranslationCatalog%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/richardpiazza/TranslationCatalog)

## Usage

Whether managing string translations as a sole developer on a single project, or as a team across multiple projects, **TranslationCatalog** has tools for you:
* Lightweight definitions for cataloging multiple languages translations
* Multiple storage options
* Command line utilities.

The _TranslationCatalog_ target includes entity definitions as well as a catalog that can persist and retrieve translations.
The primary types are:
* `Project`: A grouping of _expressions_.
* `Expression`: Core type which identifies a collection of _translations_ for a unique key.
* `Translation`: The translated value of an _expression_ for a specific Locale.

## Storage Options

**TranslationCatalog** has multiple default storage classes which all implement the `Catalog` protocol.

| Class | Medium | Notes |
| --- | --- | --- |
| `CoreDataCatalog` | CoreData (In-Memory / SQLite) | Great for Apple platforms & when persistence is not needed |
| `FilesystemCatalog` | Directories & JSON Files | Optimized for a team who is using a Git Repository as a store |
| `SQLiteCatalog` | SQLite Database | Lightweight, Fast & Cross-Platform all in a single file |

## `localizer`

A swift command line that can interact with a catalog along with importing, exporting, and documenting localizations.

**`localizer`** makes it easy to generate Localization files for different platforms. A great workflow option is to use the `FilesystemCatalog` with a
Github repo, and use Github Actions to generate updated localization files when changes are merged.

## Helpful Information

* [Apple String Format Specifiers](https://developer.apple.com/library/archive/documentation/CoreFoundation/Conceptual/CFStrings/formatSpecifiers.html#//apple_ref/doc/uid/TP40004265)
* [IEEE printf Specification](https://pubs.opengroup.org/onlinepubs/009695399/functions/printf.html)

## Contribution

Contributions to **TranslationCatalog** are welcomed and encouraged!
