#if canImport(CoreData)
import CoreData
import CoreDataPlus

enum ManagedModel: String, CaseIterable, ModelVersion, ModelCatalog {
    case v1 = "1"
    case v2 = "2"

    static var allVersions: [ManagedModel] { allCases }
    private static var models: [ManagedModel: NSManagedObjectModel] = [:]
    private static var mappings: [ManagedModel: NSMappingModel] = [:]

    var managedObjectModel: NSManagedObjectModel {
        if let model = Self.models[self] {
            return model
        }

        let resource = "CatalogModel_\(rawValue)"
        guard let model = try? Bundle.module.managedObjectModel(forResource: resource, subdirectory: "PrecompiledResources") else {
            preconditionFailure("Unable to load model for resource '\(resource)'.")
        }

        Self.models[self] = model
        return model
    }

    var mappingModel: NSMappingModel? {
        if let mapping = Self.mappings[self] {
            return mapping
        }

        let resource: String
        switch self {
        case .v1:
            return nil
        case .v2:
            resource = "Model_1_to_2"
        }

        guard let mapping = try? Bundle.module.mappingModel(forResource: resource, subdirectory: "PrecompiledResources") else {
            preconditionFailure("Update to load mapping for resource '\(resource)'.")
        }

        Self.mappings[self] = mapping
        return mapping
    }

    var previousVersion: (any ModelVersion)? {
        switch self {
        case .v1: nil
        case .v2: ManagedModel.v1
        }
    }
}
#endif
