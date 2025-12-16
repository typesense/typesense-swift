import Foundation
import Yams

struct PreprocessOpenAPI {

    static func process(input: String, output: String) throws {
        print("Reading OpenAPI spec from \(input)...")
        let yamlString = try String(contentsOfFile: input, encoding: .utf8)

        // Use compose to load as a Node tree (preserves order)
        guard var doc = try Yams.compose(yaml: yamlString) else {
            throw StringError("Failed to parse YAML as a Node tree")
        }

        print("Preprocessing the spec...")

        // Create Models from URL Parameters
        try createUrlParamsSchema(&doc, name: "AnalyticsEventsRetrieveParams", path: "/analytics/events", method: "get")

        // Unwrap Parameters
        try unwrapParametersByPath(&doc, path: "/collections/{collectionName}/documents/import", method: "post", paramName: "importDocumentsParameters", newComponentName: "ImportDocumentsParameters")
        try unwrapParametersByPath(&doc, path: "/collections/{collectionName}/documents/export", method: "get", paramName: "exportDocumentsParameters", newComponentName: "ExportDocumentsParameters")
        try unwrapParametersByPath(&doc, path: "/collections/{collectionName}/documents", method: "patch", paramName: "updateDocumentsParameters", newComponentName: "UpdateDocumentsParameters")
        try unwrapParametersByPath(&doc, path: "/collections/{collectionName}/documents", method: "delete", paramName: "deleteDocumentsParameters", newComponentName: "DeleteDocumentsParameters")
        try unwrapParametersByPath(&doc, path: "/collections", method: "get", paramName: "getCollectionsParameters", newComponentName: "GetCollectionsParameters")

        try unwrapSearchParameters(&doc)
        try unwrapMultiSearchParameters(&doc)

        try addVendorAttributes(&doc)

        print("Writing processed spec to \(output)...")

        let outputYaml = try Yams.serialize(node: doc)
        try outputYaml.write(toFile: output, atomically: true, encoding: .utf8)
        print("Successfully created \(output).")
    }

    // MARK: - Logic Implementation

    static func unwrapParametersByPath(_ doc: inout Node, path: String, method: String, paramName: String, newComponentName: String?) throws {

        guard var paths = doc["paths"],
              var pathItem = paths[path],
              var operation = pathItem[method],
              let paramsNode = operation["parameters"] else {
            print("Warning: Could not find parameters for \(method) \(path)")
            return
        }

        var parameters = paramsNode.array()

        guard let index = parameters.firstIndex(where: { $0["name"]?.string == paramName }) else {
             throw StringError("Parameter '\(paramName)' not found in \(path)")
        }

        let paramObject = parameters[index]

        guard let schema = paramObject["schema"],
              let propertiesNode = schema["properties"] else {
            throw StringError("Could not extract properties from '\(paramName)'")
        }

        if let compName = newComponentName {
            print("- Copying inline schema for '\(paramName)' to components.schemas.\(compName)...")

            if doc["components"] == nil {
                doc["components"] = Node([] as [(Node, Node)], .implicit, Node.Mapping.Style.any)
            }
            if doc["components"]?["schemas"] == nil {
                doc["components"]?["schemas"] = Node([] as [(Node, Node)], .implicit, Node.Mapping.Style.any)
            }

            doc["components"]?["schemas"]?[compName] = schema
        }

        print("- Unwrapping parameter object '\(paramName)'...")

        parameters.remove(at: index)

        if case let .mapping(propertiesMapping) = propertiesNode {
            for pair in propertiesMapping {
                let newParamPairs: [(Node, Node)] = [
                    (Node("name"), pair.key),
                    (Node("in"), Node("query")),
                    (Node("schema"), pair.value)
                ]

                let newParam = Node(newParamPairs, .implicit, Node.Mapping.Style.any)
                parameters.append(newParam)
            }
        }

        operation["parameters"] = Node(parameters, .implicit, Node.Sequence.Style.any)

        pathItem[method] = operation
        paths[path] = pathItem
        doc["paths"] = paths
    }

    static func unwrapSearchParameters(_ doc: inout Node) throws {
        guard let components = doc["components"],
              let schemas = components["schemas"],
              let searchParams = schemas["SearchParameters"],
              let properties = searchParams["properties"] else {
            throw StringError("Could not find schema for SearchParameters")
        }

        try injectPropertiesAsParams(&doc, path: "/collections/{collectionName}/documents/search", method: "get", removeParam: "searchParameters", properties: properties)
    }

    static func unwrapMultiSearchParameters(_ doc: inout Node) throws {
        guard let components = doc["components"],
              let schemas = components["schemas"],
              let searchParams = schemas["MultiSearchParameters"],
              let properties = searchParams["properties"] else {
            throw StringError("Could not find schema for MultiSearchParameters")
        }

        try injectPropertiesAsParams(&doc, path: "/multi_search", method: "post", removeParam: "multiSearchParameters", properties: properties)
    }

    // Helper for the search/multi-search unwrap
    static func injectPropertiesAsParams(_ doc: inout Node, path: String, method: String, removeParam: String, properties: Node) throws {
        print("- Unwrapping \(removeParam)...")

        guard var paths = doc["paths"],
              var pathItem = paths[path],
              var operation = pathItem[method],
              let paramsNode = operation["parameters"] else {
            return
        }

        var parameters = paramsNode.array()

        if let idx = parameters.firstIndex(where: { $0["name"]?.string == removeParam }) {
            parameters.remove(at: idx)
        }

        if case let .mapping(propertiesMapping) = properties {
            for pair in propertiesMapping {
                let newParamPairs: [(Node, Node)] = [
                    (Node("name"), pair.key),
                    (Node("in"), Node("query")),
                    (Node("schema"), pair.value)
                ]
                let newParam = Node(newParamPairs, .implicit, Node.Mapping.Style.any)
                parameters.append(newParam)
            }
        }

        operation["parameters"] = Node(parameters, .implicit, Node.Sequence.Style.any)
        pathItem[method] = operation
        paths[path] = pathItem
        doc["paths"] = paths
    }

    /// Scans a specific Path/Method, finds all Query parameters, and creates a new Schema Model in Components.
    static func createUrlParamsSchema(_ doc: inout Node, name: String, path: String, method: String) throws {
        print("- Extracting URL params from \(method.uppercased()) \(path) into schema '\(name)'...")

        guard let paths = doc["paths"],
              let pathItem = paths[path],
              let operation = pathItem[method],
              let paramsNode = operation["parameters"] else {
            print("⚠️ Warning: Path or operation not found: \(method) \(path)")
            return
        }

        let parameters = paramsNode.array()

        var propertiesMap: [(Node, Node)] = []
        var requiredFields: [String] = []

        for param in parameters {
            guard param["in"]?.string == "query",
                  let paramName = param["name"]?.string,
                  let schema = param["schema"] else {
                continue
            }

            // Copy schema properties
            var propertyDefPairs: [(Node, Node)] = []

            if case let .mapping(mapping) = schema {
                for pair in mapping {
                    propertyDefPairs.append((pair.key, pair.value))
                }
            }

            // Add/Update description
            if let description = param["description"] {
                // Remove existing description if present to avoid duplicate keys in mapping
                propertyDefPairs.removeAll(where: { $0.0.string == "description" })
                propertyDefPairs.append((Node("description"), description))
            }

            // Copy custom x-swift-type if it exists on the param level
            if let customType = param["x-swift-type"] {
                propertyDefPairs.append((Node("x-swift-type"), customType))
            }

            let propertyDef = Node(propertyDefPairs, .implicit, Node.Mapping.Style.any)

            propertiesMap.append((Node(paramName), propertyDef))

            if param["required"]?.bool == true {
                requiredFields.append(paramName)
            }
        }

        if propertiesMap.isEmpty {
            print("⚠️ No query parameters found for \(name). Skipping.")
            return
        }

        let propertiesNode = Node(propertiesMap, .implicit, Node.Mapping.Style.any)

        var schemaMap: [(Node, Node)] = [
            (Node("type"), Node("object")),
            (Node("properties"), propertiesNode)
        ]

        if !requiredFields.isEmpty {
            let requiredNodes = requiredFields.map { Node($0) }
            schemaMap.append((Node("required"), Node(requiredNodes, .implicit, Node.Sequence.Style.any)))
        }

        let newSchema = Node(schemaMap, .implicit, Node.Mapping.Style.any)

        if doc["components"] == nil {
            doc["components"] = Node([] as [(Node, Node)], .implicit, Node.Mapping.Style.any)
        }
        if doc["components"]?["schemas"] == nil {
            doc["components"]?["schemas"] = Node([] as [(Node, Node)], .implicit, Node.Mapping.Style.any)
        }

        doc["components"]?["schemas"]?[name] = newSchema

        print("  ✅ Created schema '\(name)' with \(propertiesMap.count) properties.")
    }
}

struct StringError: Error, CustomStringConvertible {
    let message: String
    var description: String { return message }
    init(_ message: String) { self.message = message }
}