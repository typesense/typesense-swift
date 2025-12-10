import Foundation
import Yams

class VendorAttributes {
    var doc: Node

    init(doc: Node) {
        self.doc = doc
    }

    /// Helper to modify a specific schema in place
    private func modifySchema(_ name: String, closure: (inout Node) -> Void) throws {
        guard var components = doc["components"],
              var schemas = components["schemas"] else {
             return
        }

        guard var schema = schemas[name] else {
            throw StringError( "Schema not found: \(name)")
        }

        closure(&schema)

        // Write back up the tree
        schemas[name] = schema
        components["schemas"] = schemas
        doc["components"] = components
    }

    /// Adds x-swift-generic-parameter to the schema
    func schemaGenericParameter(_ items: [(String, String)]) throws {
        for (schemaName, generic) in items {
            try modifySchema(schemaName) { schema in
                schema["x-swift-generic-parameter"] = Node(generic)
            }
        }
    }

    /// Overrides field types in a schema "x-swift-type"
    func schemaFieldTypeOverrides(schema: String, overrides: [(String, String)]) throws {
        try modifySchema(schema) { schemaNode in
            guard var properties = schemaNode["properties"] else { return }

            for (field, swiftType) in overrides {
                if var existingProp = properties[field] {
                    // Update existing
                    existingProp["x-swift-type"] = Node(swiftType)
                    properties[field] = existingProp
                } else {
                    // Create new
                    let newPropPairs: [(Node, Node)] = [
                        (Node("x-swift-type"), Node(swiftType))
                    ]
                    let newProp = Node(newPropPairs, .implicit, Node.Mapping.Style.any)
                    properties[field] = newProp
                }
            }

            schemaNode["properties"] = properties
        }
    }
}