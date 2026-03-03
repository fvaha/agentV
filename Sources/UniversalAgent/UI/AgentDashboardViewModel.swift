import Foundation
import Combine

@MainActor
public final class AgentDashboardViewModel: ObservableObject {
    private let agent: UniversalAgent
    private let profileStore: AgentProfileStore

    @Published public var systemPrompt: String
    @Published public var userPrompt: String = ""
    @Published public var lastResponse: String = ""
    @Published public var isRunning: Bool = false
    @Published public var contextItems: [String: String] = [:]
    @Published public var tools: [Tool] = []
    @Published public var enabledToolNames: Set<String> = []
    @Published public var profiles: [AgentProfile] = []
    @Published public var selectedProfileID: String?

    public init(
        agent: UniversalAgent,
        initialSystemPrompt: String = "You are a helpful local Swift agent.",
        profileStore: AgentProfileStore = .shared
    ) {
        self.agent = agent
        self.profileStore = profileStore
        self.systemPrompt = initialSystemPrompt
    }

    public func loadInitialData() {
        Task {
            let currentContext = await agent.currentContext()
            let availableTools = await agent.availableTools()

            var loadedProfiles = profileStore.loadProfiles()
            if loadedProfiles.isEmpty {
                loadedProfiles = profileStore.ensureDefaultProfiles(
                    tools: availableTools,
                    defaultSystemPrompt: systemPrompt
                )
            }

            profiles = loadedProfiles

            let storedSelectedID = profileStore.loadSelectedProfileID()
            let initialProfile: AgentProfile?

            if let storedSelectedID,
               let found = loadedProfiles.first(where: { $0.id == storedSelectedID }) {
                initialProfile = found
            } else {
                initialProfile = loadedProfiles.first
            }

            if let profile = initialProfile {
                apply(profile: profile, allTools: availableTools)
            } else {
                let initialEnabledNames = Set(availableTools.map(\.name))
                enabledToolNames = initialEnabledNames
                await agent.setEnabledTools(initialEnabledNames)
            }

            self.contextItems = currentContext
            self.tools = availableTools
        }
    }

    public func refreshContext() {
        Task {
            let currentContext = await agent.currentContext()
            self.contextItems = currentContext
        }
    }

    public func selectProfile(id: String) {
        guard let profile = profiles.first(where: { $0.id == id }) else { return }
        Task {
            let availableTools = await agent.availableTools()
            apply(profile: profile, allTools: availableTools)
        }
        profileStore.saveSelectedProfileID(id)
    }

    private func apply(profile: AgentProfile, allTools: [Tool]) {
        selectedProfileID = profile.id
        systemPrompt = profile.settings.systemPrompt

        let allNames = Set(allTools.map(\.name))
        let enabled = Set(profile.settings.enabledToolNames).intersection(allNames)

        enabledToolNames = enabled.isEmpty ? allNames : enabled

        Task {
            await agent.setEnabledTools(enabledToolNames)
        }
    }

    public func isToolEnabled(_ name: String) -> Bool {
        enabledToolNames.contains(name)
    }

    public func setTool(_ name: String, enabled: Bool) {
        if enabled {
            enabledToolNames.insert(name)
        } else {
            enabledToolNames.remove(name)
        }

        let namesToSet = enabledToolNames

        Task {
            await agent.setEnabledTools(namesToSet)
        }

        persistSettings()
    }

    private func persistSettings() {
        guard let selectedProfileID,
              let index = profiles.firstIndex(where: { $0.id == selectedProfileID })
        else { return }

        let updatedSettings = AgentSettings(
            systemPrompt: systemPrompt,
            enabledToolNames: Array(enabledToolNames)
        )
        profiles[index].settings = updatedSettings
        profileStore.saveProfiles(profiles)
        profileStore.saveSelectedProfileID(selectedProfileID)
    }

    public func run() {
        guard isRunning == false else { return }

        isRunning = true

        Task {
            defer { isRunning = false }

            do {
                let (response, _) = try await agent.runWithToolCalls(
                    systemPrompt: systemPrompt,
                    userPrompt: userPrompt,
                    extraContext: [:]
                )

                self.lastResponse = response
                let updatedContext = await agent.currentContext()
                self.contextItems = updatedContext

                self.persistSettings()
            } catch {
                self.lastResponse = "Error: \(error.localizedDescription)"
            }
        }
    }
}

