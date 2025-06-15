import Foundation
import LocaleSupport

/// Interface providing storage and retrieval of the `Expression`s and associated `Translation`s.
public protocol Catalog {
    // MARK: - Project

    /// Retrieve all `Project`s in the catalog.
    func projects() throws -> [Project]
    /// Retrieve all `Project`s that match the provided query parameters
    ///
    /// - parameter query: Parameters that filter the results
    func projects(matching query: CatalogQuery) throws -> [Project]
    /// Retrieve a single project for the provided identifier.
    ///
    /// - parameter id: The unique identifier for the `Project`
    func project(_ id: Project.ID) throws -> Project
    /// Retrieves the first `Project` matching the query
    ///
    /// - parameter query: Parameters that filter the results
    func project(matching query: CatalogQuery) throws -> Project
    /// Inserts a `Project` into the catalog.
    ///
    /// - parameter project: The entity to insert.
    /// - returns The unique identifier created for the new entity.
    @discardableResult func createProject(_ project: Project) throws -> Project.ID
    /// Modifies a `Project` in the catalog.
    ///
    /// - parameter id: The unique identifier for the `Project`
    /// - parameter action: The update to perform on the entity matching the provided id.
    func updateProject(_ id: Project.ID, action: CatalogUpdate) throws
    /// Removes a `Project` from the catalog.
    ///
    /// This should remove the `Project` only. Any `Expression`s that were linked to the project should remain intact, as expressions
    /// can live independently from a project.
    ///
    /// - parameter id: The unique identifier for the `Project`.
    func deleteProject(_ id: Project.ID) throws

    // MARK: - Expression

    func expressions() throws -> [Expression]
    func expressions(matching query: CatalogQuery) throws -> [Expression]
    func expression(_ id: Expression.ID) throws -> Expression
    func expression(matching query: CatalogQuery) throws -> Expression
    /// Insert a `Expression` into the catalog.
    ///
    /// - parameter expression: The entity to insert.
    /// - returns The unique identifier created for the new entity.
    @discardableResult func createExpression(_ expression: Expression) throws -> Expression.ID
    func updateExpression(_ id: Expression.ID, action: CatalogUpdate) throws
    /// Remove a `Expression` from the catalog.
    ///
    /// When removed, the `Translation`s linked to the expression should be removed - as well as - any references that
    /// a `Project` may hold to the expression.
    ///
    /// - parameter id: The unique identifier for the `Expression`.
    func deleteExpression(_ id: Expression.ID) throws

    // MARK: - Translation

    func translations() throws -> [Translation]
    func translations(matching query: CatalogQuery) throws -> [Translation]
    func translation(_ id: Translation.ID) throws -> Translation
    func translation(matching query: CatalogQuery) throws -> Translation
    /// Insert a `Translation` into the catalog.
    ///
    /// - parameter translation: The entity to insert.
    /// - returns The unique identifier created for the new entity.
    @discardableResult func createTranslation(_ translation: Translation) throws -> Translation.ID
    /// Update a single `Translation` in the catalog.
    ///
    /// - parameter id: The unique identifier for the `Translation`.
    /// - parameter action: The update to perform on the entity matching the provided id.
    func updateTranslation(_ id: Translation.ID, action: CatalogUpdate) throws
    /// Remove a `Translation` from the catalog.
    ///
    /// - parameter id: The unique identifier for the `Translation`.
    func deleteTranslation(_ id: Translation.ID) throws

    // MARK: - Metadata

    func localeIdentifiers() throws -> Set<Locale.Identifier>
}
