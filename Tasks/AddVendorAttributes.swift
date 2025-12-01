func addVendorAttributes(_ doc: inout [String: Any]) throws {
    print("Adding custom x-* vendor attributes...")
    let attrs = VendorAttributes(doc: doc)

    // Generic Parameters
    // Setting "x-swift-generic-parameter"
    try attrs.schemaGenericParameter([
        ("SearchResult", "T"),
        ("SearchGroupedHit", "T"),
        ("SearchResultHit", "T"),
        ("MultiSearchResult", "T"),
        ("MultiSearchResultItem", "T"),
    ])

    // Field Type Overrides
    try attrs.schemaFieldTypeOverrides(
        schema: "SearchResult",
        overrides: [
            ("hits", "[SearchResultHit<T>]"),
            ("grouped_hits", "[SearchGroupedHit<T>]"),
        ]
    )

    try attrs.schemaFieldTypeOverrides(
        schema: "SearchGroupedHit",
        overrides: [("hits", "[SearchResultHit<T>]")]
    )

    try attrs.schemaFieldTypeOverrides(
        schema: "SearchResultHit",
        overrides: [("document", "T")]
    )

    try attrs.schemaFieldTypeOverrides(
        schema: "MultiSearchResult",
        overrides: [("results", "[MultiSearchResultItem<T>]")]
    )

    // Save changes back to the inout parameter
    doc = attrs.doc
}
