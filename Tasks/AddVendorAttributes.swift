func addVendorAttributes(_ doc: inout [String: Any]) throws {
    print("Adding custom x-* vendor attributes...")
    let attrs = VendorAttributes(doc: doc)

    // Generic Parameters
    // Setting "x-swift-generic-parameter"
    try attrs.schemaGenericParameter([
        ("SearchResult", "T: Codable"),
        ("SearchGroupedHit", "T: Codable"),
        ("SearchResultHit", "T: Codable"),
        ("MultiSearchResult", "T: Codable"),
        ("MultiSearchResultItem", "T: Codable"),
    ])

    // Field Type Overrides "x-swift-type"
    try attrs.schemaFieldTypeOverrides(
        schema: "SearchResult",
        overrides: [
            ("hits", "[SearchResultHit<T>]?"),
            ("grouped_hits", "[SearchGroupedHit<T>]?"),
        ]
    )

    try attrs.schemaFieldTypeOverrides(
        schema: "SearchGroupedHit",
        overrides: [("hits", "[SearchResultHit<T>]?")]
    )

    try attrs.schemaFieldTypeOverrides(
        schema: "SearchResultHit",
        overrides: [("document", "T?")]
    )

    try attrs.schemaFieldTypeOverrides(
        schema: "MultiSearchResult",
        overrides: [("results", "[MultiSearchResultItem<T>]?")]
    )

    // Save changes back to the inout parameter
    doc = attrs.doc
}
