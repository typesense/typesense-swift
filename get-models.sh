curl https://raw.githubusercontent.com/typesense/typesense-api-spec/master/openapi.yml > openapi.yml
swagger-codegen generate -i openapi.yml -l swift5 -o output
rm -rf Models
cd output/SwaggerClient/Classes/Swaggers
mv ./Models ../../../../
cd ../../../../
rm -rf output

cd Models

# Delete useless structs generated as a mistake by the code-gen
rm OneOfSearchParametersMaxHits.swift
rm OneOfMultisearchParametersMaxHits.swift

# Fix the maxHits type by defining it as a String Optional
find . -name "SearchParameters.swift" -exec sed -i '' 's/maxHits: OneOfSearchParametersMaxHits\?/maxHits: String\?/g' {} \;
find . -name "MultiSearchParameters.swift" -exec sed -i '' 's/maxHits: OneOfMultiSearchParametersMaxHits\?/maxHits: String\?/g' {} \;
find . -name "MultiSearchCollectionParameters.swift" -exec sed -i '' 's/maxHits: Any\?/maxHits: String\?/g' {} \;

# Add Generics to SearchResult
find . -name "SearchResult.swift" -exec sed -i '' 's/SearchResult:/SearchResult<T: Codable>:/g' {} \;
find . -name "SearchResult.swift" -exec sed -i '' 's/groupedHits: \[SearchGroupedHit\]\?/groupedHits: \[SearchGroupedHit<T>\]\?/g' {} \; 
find . -name "SearchResult.swift" -exec sed -i '' 's/hits: \[SearchResultHit\]\?/hits: \[SearchResultHit<T>\]\?/g' {} \;

# Add Generics to MultiSearchResult
find . -name "MultiSearchResult.swift" -exec sed -i '' 's/results: \[SearchResult\]/results: \[SearchResult<T>\]/g' {} \;
find . -name "MultiSearchResult.swift" -exec sed -i '' 's/MultiSearchResult:/MultiSearchResult<T: Codable>:/g' {} \;

# Add Generics to SearchResultHit
find . -name "SearchResultHit.swift" -exec sed -i '' 's/SearchResultHit:/SearchResultHit<T: Codable>:/g' {} \;

# Convert document parameter to a generic T
find . -name "SearchResultHit.swift" -exec sed -i '' 's/document: \[String:Any\]\?/document: T?/g' {} \;

# Add Generics to SearchGroupedHit
find . -name "SearchGroupedHit.swift" -exec sed -i '' 's/SearchGroupedHit:/SearchGroupedHit<T: Codable>:/g' {} \;
find . -name "SearchGroupedHit.swift" -exec sed -i '' 's/hits: \[SearchResultHit\]/hits: \[SearchResultHit<T>\]/g' {} \;

# Convert matchedTokens to custom defined StringQuantum
find . -name "SearchHighlight.swift" -exec sed -i '' 's/matchedTokens: \[Any\]\?/matchedTokens: StringQuantum\?/g' {} \;






