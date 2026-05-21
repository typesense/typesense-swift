Pod::Spec.new do |spec|
  spec.name         = "Typesense"
  spec.version      = "2.0.0"
  spec.summary      = "Swift client library for Typesense Search Engine"
  spec.description  = <<-DESC
                      Typesense Swift SDK client is a Swift wrapper around the Typesense Search API.
                      An open-source, developer-friendly, fast search engine.
                      DESC

  spec.homepage     = "https://typesense.org"
  spec.license      = { :type => "Apache-2.0", :file => "LICENSE" }
  spec.author       = { "Typesense" => "contact@typesense.org" }

  spec.ios.deployment_target = "13.0"
  spec.osx.deployment_target = "10.15"

  spec.source       = { :git => "https://github.com/typesense/typesense-swift.git", :tag => "v#{spec.version}" }
  
  spec.source_files  = "Sources/Typesense/**/*.swift"
  spec.swift_version = "5.5"

  spec.dependency "AnyCodable-FlightSchool", "~> 0.6.0"

  spec.pod_target_xcconfig = {
    'IPHONEOS_DEPLOYMENT_TARGET' => '13.0',
    'MACOSX_DEPLOYMENT_TARGET' => '10.15'
  }
end
