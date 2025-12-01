import Foundation
import Yams

struct PreprocessOpenAPI {

    // Typealias for our Generic JSON/YAML object
    typealias Node = [String: Any]

    static func process(input: String, output: String) throws {
        print("Reading OpenAPI spec from \(input)...")
        let yamlString = try String(contentsOfFile: input, encoding: .utf8)

        // Load as a Generic Dictionary
        guard var doc = try Yams.load(yaml: yamlString) as? Node else {
            throw StringError("Failed to parse YAML as a dictionary")
        }

        print("Preprocessing the spec...")

        // Add Vendor Attributes
        try addVendorAttributes(&doc)

        // Unwrap Parameters
        try unwrapParametersByPath(&doc, path: "/collections/{collectionName}/documents/import", method: "post", paramName: "importDocumentsParameters", newComponentName: "ImportDocumentsParameters")

        try unwrapParametersByPath(&doc, path: "/collections/{collectionName}/documents/export", method: "get", paramName: "exportDocumentsParameters", newComponentName: "ExportDocumentsParameters")

        try unwrapParametersByPath(&doc, path: "/collections/{collectionName}/documents", method: "patch", paramName: "updateDocumentsParameters", newComponentName: "UpdateDocumentsParameters")

        try unwrapParametersByPath(&doc, path: "/collections/{collectionName}/documents", method: "delete", paramName: "deleteDocumentsParameters", newComponentName: "DeleteDocumentsParameters")

        try unwrapParametersByPath(&doc, path: "/collections", method: "get", paramName: "getCollectionsParameters", newComponentName: "GetCollectionsParameters")

        try unwrapSearchParameters(&doc)
        try unwrapMultiSearchParameters(&doc)


        print("Writing processed spec to \(output)...")
        let outputYaml = try Yams.dump(object: doc)
        try outputYaml.write(toFile: output, atomically: true, encoding: .utf8)
        print("Successfully created \(output).")
    }

    // MARK: - Logic Implementation

    static func unwrapParametersByPath(_ doc: inout Node, path: String, method: String, paramName: String, newComponentName: String?) throws {

        // Navigate to Paths -> Path -> Method -> Parameters
        guard var paths = doc["paths"] as? Node,
              var pathItem = paths[path] as? Node,
              var operation = pathItem[method] as? Node,
              var parameters = operation["parameters"] as? [Node] else {
            // Path might not exist, simply return or log warning
            print("Warning: Could not find parameters for \(method) \(path)")
            return
        }

        // Find the parameter to unwrap
        guard let index = parameters.firstIndex(where: { ($0["name"] as? String) == paramName }),
              let paramObject = parameters[index] as Node? else {
             throw StringError("Parameter '\(paramName)' not found in \(path)")
        }

        // Extract Schema
        guard let schema = paramObject["schema"] as? Node,
              let properties = schema["properties"] as? Node else {
            throw StringError("Could not extract properties from '\(paramName)'")
        }

        // Copy to Components (Optional)
        if let compName = newComponentName {
            print("- Copying inline schema for '\(paramName)' to components.schemas.\(compName)...")
            var components = doc["components"] as? Node ?? [:]
            var schemas = components["schemas"] as? Node ?? [:]
            schemas[compName] = schema
            components["schemas"] = schemas
            doc["components"] = components
        }

        print("- Unwrapping parameter object '\(paramName)'...")

        // Remove the object parameter
        parameters.remove(at: index)

        // Add flattened properties
        for (key, value) in properties {
            let newParam: Node = [
                "name": key,
                "in": "query",
                "schema": value
            ]
            parameters.append(newParam)
        }

        // Save back up the tree
        operation["parameters"] = parameters
        pathItem[method] = operation
        paths[path] = pathItem
        doc["paths"] = paths
    }

    static func unwrapSearchParameters(_ doc: inout Node) throws {
        // Reusing the generic logic to modify the Search path

        guard let components = doc["components"] as? Node,
              let schemas = components["schemas"] as? Node,
              let searchParams = schemas["SearchParameters"] as? Node,
              let properties = searchParams["properties"] as? Node else {
            throw StringError("Could not find schema for SearchParameters")
        }

        let path = "/collections/{collectionName}/documents/search"
        let method = "get"

        try injectPropertiesAsParams(&doc, path: path, method: method, removeParam: "searchParameters", properties: properties)
    }

    static func unwrapMultiSearchParameters(_ doc: inout Node) throws {
        guard let components = doc["components"] as? Node,
              let schemas = components["schemas"] as? Node,
              let searchParams = schemas["MultiSearchParameters"] as? Node,
              let properties = searchParams["properties"] as? Node else {
            throw StringError("Could not find schema for MultiSearchParameters")
        }

        let path = "/multi_search"
        let method = "post"

        try injectPropertiesAsParams(&doc, path: path, method: method, removeParam: "multiSearchParameters", properties: properties)
    }

    // Helper for the search/multi-search unwrap
    static func injectPropertiesAsParams(_ doc: inout Node, path: String, method: String, removeParam: String, properties: Node) throws {
        print("- Unwrapping \(removeParam)...")

        guard var paths = doc["paths"] as? Node,
              var pathItem = paths[path] as? Node,
              var operation = pathItem[method] as? Node,
              var parameters = operation["parameters"] as? [Node] else {
            return
        }

        if let idx = parameters.firstIndex(where: { ($0["name"] as? String) == removeParam }) {
            parameters.remove(at: idx)
        }

        for (key, value) in properties {
            let newParam: Node = [
                "name": key,
                "in": "query",
                "schema": value
            ]
            parameters.append(newParam)
        }

        operation["parameters"] = parameters
        pathItem[method] = operation
        paths[path] = pathItem
        doc["paths"] = paths
    }

}

struct StringError: Error, CustomStringConvertible {
    let message: String
    var description: String { return message }
    init(_ message: String) { self.message = message }
}