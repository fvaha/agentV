import Foundation

public struct AgentSettings: Codable, Sendable {
    public var systemPrompt: String
    public var enabledToolNames: [String]

    public init(systemPrompt: String, enabledToolNames: [String]) {
        self.systemPrompt = systemPrompt
        self.enabledToolNames = enabledToolNames
    }
}

public final class AgentSettingsStore: @unchecked Sendable {
    public static let shared = AgentSettingsStore()

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func load(forKey key: String) -> AgentSettings? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        return try? decoder.decode(AgentSettings.self, from: data)
    }

    public func save(_ settings: AgentSettings, forKey key: String) {
        guard let data = try? encoder.encode(settings) else { return }
        defaults.set(data, forKey: key)
    }
}

