import SwiftUI

public struct AgentDashboardView: View {
    @StateObject private var viewModel: AgentDashboardViewModel

    public init(agent: UniversalAgent, initialSystemPrompt: String = "You are a helpful local Swift agent.") {
        _viewModel = StateObject(
            wrappedValue: AgentDashboardViewModel(
                agent: agent,
                initialSystemPrompt: initialSystemPrompt
            )
        )
    }

    public var body: some View {
        NavigationStack {
            Form {
                if viewModel.profiles.isEmpty == false {
                    Section("Profile") {
                        Picker("Profile", selection: Binding(
                            get: { viewModel.selectedProfileID ?? viewModel.profiles.first?.id },
                            set: { newValue in
                                if let id = newValue {
                                    viewModel.selectProfile(id: id)
                                }
                            }
                        )) {
                            ForEach(viewModel.profiles) { profile in
                                Text(profile.name).tag(Optional.some(profile.id))
                            }
                        }
                    }
                }

                Section("System prompt") {
                    TextEditor(text: $viewModel.systemPrompt)
                        .frame(minHeight: 80)
                }

                Section("User prompt") {
                    TextEditor(text: $viewModel.userPrompt)
                        .frame(minHeight: 80)

                    Button {
                        viewModel.run()
                    } label: {
                        HStack {
                            if viewModel.isRunning {
                                ProgressView()
                            }
                            Text("Run agent")
                        }
                    }
                    .disabled(viewModel.isRunning || viewModel.userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if viewModel.lastResponse.isEmpty == false {
                    Section("Last response") {
                        ScrollView {
                            Text(viewModel.lastResponse)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                if viewModel.tools.isEmpty == false {
                    Section("Tools / skills") {
                        ForEach(viewModel.tools, id: \.name) { tool in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tool.name)
                                        .font(.headline)
                                    Text(tool.description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Toggle(isOn: Binding(
                                    get: { viewModel.isToolEnabled(tool.name) },
                                    set: { viewModel.setTool(tool.name, enabled: $0) }
                                )) {
                                    EmptyView()
                                }
                                .labelsHidden()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                if viewModel.contextItems.isEmpty == false {
                    Section("Context") {
                        ForEach(viewModel.contextItems.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(key)
                                    .font(.headline)
                                Text(value)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Agent Dashboard")
            .onAppear {
                viewModel.loadInitialData()
            }
        }
    }
}

#if DEBUG
struct AgentDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        Text("AgentDashboardView preview placeholder")
    }
}
#endif

