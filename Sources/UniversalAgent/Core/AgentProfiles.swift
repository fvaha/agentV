import Foundation

public struct AgentProfile: Codable, Identifiable, Sendable {
    public var id: String
    public var name: String
    public var settings: AgentSettings

    public init(id: String, name: String, settings: AgentSettings) {
        self.id = id
        self.name = name
        self.settings = settings
    }
}

public final class AgentProfileStore: @unchecked Sendable {
    public static let shared = AgentProfileStore()

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private let profilesKey = "UniversalAgent.Profiles"
    private let selectedProfileKey = "UniversalAgent.SelectedProfileID"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func loadProfiles() -> [AgentProfile] {
        guard let data = defaults.data(forKey: profilesKey) else {
            return []
        }
        return (try? decoder.decode([AgentProfile].self, from: data)) ?? []
    }

    public func saveProfiles(_ profiles: [AgentProfile]) {
        guard let data = try? encoder.encode(profiles) else { return }
        defaults.set(data, forKey: profilesKey)
    }

    public func loadSelectedProfileID() -> String? {
        defaults.string(forKey: selectedProfileKey)
    }

    public func saveSelectedProfileID(_ id: String) {
        defaults.set(id, forKey: selectedProfileKey)
    }

    public func ensureDefaultProfiles(
        tools: [Tool],
        defaultSystemPrompt: String
    ) -> [AgentProfile] {
        let allToolNames = tools.map(\.name)

        let baseSettings = AgentSettings(
            systemPrompt: defaultSystemPrompt,
            enabledToolNames: allToolNames
        )

        // Svi profili startuju sa istim tool‑ovima; korisnik ih posle uključi/isključi
        // prema use‑case‑u. Imena profila su semantička.
        let profiles: [AgentProfile] = [
            AgentProfile(
                id: "default",
                name: "Default",
                settings: baseSettings
            ),
            AgentProfile(
                id: "tutor",
                name: "Tutor",
                settings: baseSettings
            ),
            AgentProfile(
                id: "mail",
                name: "Mail assistant",
                settings: baseSettings
            ),
            AgentProfile(
                id: "voice",
                name: "Voice assistant",
                settings: baseSettings
            )
        ]

        saveProfiles(profiles)
        saveSelectedProfileID("default")
        return profiles
    }
}

