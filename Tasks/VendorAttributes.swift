import Foundation
import Yams

/// Helper class to manipulate the nested Dictionary structure
class VendorAttributes {
    var doc: [String: Any]

    // Quick accessors for Components -> Schemas
    var schemas: [String: Any] {
        get {
            guard let components = doc["components"] as? [String: Any],
                  let schemas = components["schemas"] as? [String: Any] else {
                return [:]
            }
            return schemas
        }
        set {
            var components = doc["components"] as? [String: Any] ?? [:]
            components["schemas"] = newValue
            doc["components"] = components
        }
    }

    init(doc: [String: Any]) {
        self.doc = doc
    }

    /// Helper to modify a specific schema in place
    private func modifySchema(_ name: String, closure: (inout [String: Any]) -> Void) throws {
        var currentSchemas = self.schemas

        guard var schema = currentSchemas[name] as? [String: Any] else {
            throw StringError( "Schema not found: \(name)")
        }

        closure(&schema)

        currentSchemas[name] = schema
        self.schemas = currentSchemas
    }

    /// Adds x-swift-generic-parameter to the schema
    func schemaGenericParameter(_ items: [(String, String)]) throws {
        for (schemaName, generic) in items {
            try modifySchema(schemaName) { schema in
                schema["x-swift-generic-parameter"] = generic
            }
        }
    }

    /// Overrides field types in a schema
    func schemaFieldTypeOverrides(schema: String, overrides: [(String, String)]) throws {
        try modifySchema(schema) { schemaDict in
            var properties = schemaDict["properties"] as? [String: Any] ?? [:]

            for (field, swiftType) in overrides {
                if var existingProp = properties[field] as? [String: Any] {
                    // Update existing
                    existingProp["x-swift-type"] = swiftType
                    properties[field] = existingProp
                } else {
                    // Create new if missing (matches Rust 'None' branch)
                    let newProp: [String: Any] = ["x-swift-type": swiftType]
                    properties[field] = newProp
                }
            }

            schemaDict["properties"] = properties
        }
    }
}
