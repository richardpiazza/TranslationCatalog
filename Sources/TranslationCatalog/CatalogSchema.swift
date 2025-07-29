/// Internal reference (could be public eventually if schema controls are exposed)
///
/// Entities or Catalogs could potentially track this.
enum CatalogSchema {
    /// Initial schema for each catalog when not otherwise noted.
    case undefined
    /// `Expression.defaultValue` added.
    case alpha_1
}
