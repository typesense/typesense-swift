import Foundation
import ArgumentParser
import Yams

let specUrl = "https://raw.githubusercontent.com/typesense/typesense-api-spec/master/openapi.yml"
let inputSpecFile = "openapi.yml"
let outputPreprocessedFile = "preprocessed_openapi.yml"
let customTemplatesDir = "openapi-generator-template"
let outputDir = "typesense_codegen"

struct Tasks: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "A task runner for the typesense-swift project",
        subcommands: [CodeGen.self, Fetch.self, Preprocess.self]
    )
}

// MARK: - Tasks

struct CodeGen: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Generates client code using Docker and moves Models to Sources.")

    func run() throws {
        print("▶️  Running codegen task via Docker...")

        let fileManager = FileManager.default
        let currentPath = fileManager.currentDirectoryPath

        let volumeMount = "\(currentPath):/local"

        let dockerArgs = [
            "run", "--rm",
            "-v", volumeMount,
            "openapitools/openapi-generator-cli",
            "generate",
            "-i", "/local/\(outputPreprocessedFile)",
            "-g", "swift5",
            "-o", "/local/output",
            "--additional-properties", "useJsonEncodable=false",
            "--additional-properties", "hashableModels=false",
            "--additional-properties", "identifiableModels=false"
        ]

        print("  - Executing Docker generate command...")
        try Shell.run("docker", args: dockerArgs)

        // Define paths for file operations
        // Path logic based on: cd output/OpenAPIClient/Classes/OpenAPIs
        let generatedModelsPath = "output/OpenAPIClient/Classes/OpenAPIs/Models"
        let tempModelsPath = "Models"
        let outputDir = "output"
        let finalDestination = "Sources/Typesense"
        let finalModelsPath = "\(finalDestination)/Models"

        // rm -rf Models (Clean up any existing temp folder in root)
        if fileManager.fileExists(atPath: tempModelsPath) {
            print("  - Cleaning up temporary Models directory...")
            try Shell.run("rm", args: ["-rf", tempModelsPath])
        }

        // mv ./output/.../Models ../../../../ (Move generated models to root)
        print("  - Extracting Models from generated output...")
        // We verify the generated path exists first to avoid confusing errors
        if !fileManager.fileExists(atPath: generatedModelsPath) {
            print("❌ Error: Generated models not found at \(generatedModelsPath). Docker generation might have failed.")
            throw ExitCode.failure
        }
        try Shell.run("mv", args: [generatedModelsPath, "."])

        // rm -rf output
        print("  - Removing raw output directory...")
        try Shell.run("rm", args: ["-rf", outputDir])

        // rm -rf Sources/Typesense/Models
        print("  - Removing old Models from \(finalDestination)...")
        try Shell.run("rm", args: ["-rf", finalModelsPath])

        // mv ./Models ./Sources/Typesense
        print("  - Moving new Models to \(finalDestination)...")

        // Ensure destination folder exists, otherwise mv will fail or rename the folder to Typesense
        var isDir: ObjCBool = false
        if !fileManager.fileExists(atPath: finalDestination, isDirectory: &isDir) || !isDir.boolValue {
            print("❌ Error: Destination directory '\(finalDestination)' does not exist.")
            throw ExitCode.failure
        }

        try Shell.run("mv", args: [tempModelsPath, finalDestination])

        print("✅ Codegen and file movement finished successfully.")
    }
}

struct Fetch: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Fetches the latest OpenAPI spec.")

    func run() throws {
        print("▶️  Running fetch task...")
        print("  - Downloading spec from \(specUrl)")

        guard let url = URL(string: specUrl),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to download spec.")
            throw ExitCode.failure
        }

        try data.write(to: URL(fileURLWithPath: inputSpecFile))
        print("  - Spec saved to \(inputSpecFile)")
        print("✅ Fetch API spec task finished successfully.")
    }
}

struct Preprocess: ParsableCommand {
    static var configuration = CommandConfiguration(abstract: "Preprocesses the OpenAPI spec.")

    func run() throws {
        print("▶️  Preprocessing OpenAPI file...")
        try PreprocessOpenAPI.process(input: inputSpecFile, output: outputPreprocessedFile)
        print("✅ Preprocessing complete.")
    }
}

// MARK: - Helpers

struct Shell {
    static func run(_ command: String, args: [String]) throws {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = [command] + args
        try task.run()
        task.waitUntilExit()

        if task.terminationStatus != 0 {
            throw ExitCode(task.terminationStatus)
        }
    }
}

Tasks.main()
