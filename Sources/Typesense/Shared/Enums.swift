public enum IndexAction: String, Codable {
    case create = "create"
    case update = "update"
    case upsert = "upsert"
    case emplace = "emplace"
}

public enum DirtyValues: String, Codable {
    case coerceOrReject = "coerce_or_reject"
    case coerceOrDrop = "coerce_or_drop"
    case drop = "drop"
    case reject = "reject"
}