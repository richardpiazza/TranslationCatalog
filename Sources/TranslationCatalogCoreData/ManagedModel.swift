#if canImport(CoreData)
import CoreData
import CoreDataPlus

enum ManagedModel: String, CaseIterable, ModelVersion, ModelCatalog {
    case v1 = "1"

    static var allVersions: [ManagedModel] { allCases }
    private static var models: [ManagedModel: NSManagedObjectModel] = [:]

    var managedObjectModel: NSManagedObjectModel {
        if let model = Self.models[self] {
            return model
        }

        let resource = "CatalogModel"
        guard let model = try? Bundle.module.managedObjectModel(forResource: resource, subdirectory: "PrecompiledResources") else {
            preconditionFailure("Unable to load model for resource '\(resource)'.")
        }

        Self.models[self] = model
        return model
    }

    var mappingModel: NSMappingModel? { nil }

    var previousVersion: (any ModelVersion)? { nil }
}
#endif
