import Foundation

public struct Tool: Codable, Sendable {
    public let name: String
    public let description: String
    public let arguments: [String: ToolArgumentType]

    public init(
        name: String,
        description: String,
        arguments: [String: ToolArgumentType] = [:]
    ) {
        self.name = name
        self.description = description
        self.arguments = arguments
    }
}

public indirect enum ToolArgumentType: Codable, Sendable {
    case string
    case integer
    case double
    case boolean
    case array(ToolArgumentType)
    case object([String: ToolArgumentType])

    private enum CodingKeys: String, CodingKey {
        case kind
        case items
        case properties
    }

    private enum Kind: String, Codable {
        case string
        case integer
        case double
        case boolean
        case array
        case object
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)

        switch kind {
        case .string:
            self = .string
        case .integer:
            self = .integer
        case .double:
            self = .double
        case .boolean:
            self = .boolean
        case .array:
            let elementType = try container.decode(ToolArgumentType.self, forKey: .items)
            self = .array(elementType)
        case .object:
            let properties = try container.decode([String: ToolArgumentType].self, forKey: .properties)
            self = .object(properties)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .string:
            try container.encode(Kind.string, forKey: .kind)
        case .integer:
            try container.encode(Kind.integer, forKey: .kind)
        case .double:
            try container.encode(Kind.double, forKey: .kind)
        case .boolean:
            try container.encode(Kind.boolean, forKey: .kind)
        case .array(let elementType):
            try container.encode(Kind.array, forKey: .kind)
            try container.encode(elementType, forKey: .items)
        case .object(let properties):
            try container.encode(Kind.object, forKey: .kind)
            try container.encode(properties, forKey: .properties)
        }
    }
}

