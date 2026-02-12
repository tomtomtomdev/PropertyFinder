import SwiftUI

struct DebugMenuView: View {
    @State private var flags = FeatureFlagProvider.shared.allFlags
    @State private var experiments = ABTestEngine.allExperiments

    var body: some View {
        NavigationStack {
            List {
                Section("Feature Flags") {
                    ForEach(flags, id: \.key) { flag in
                        Toggle(isOn: Binding(
                            get: { FeatureFlagProvider.shared.isEnabled(flag.key) },
                            set: { newValue in
                                FeatureFlagProvider.shared.setOverride(flag.key, value: newValue)
                                refreshFlags()
                            }
                        )) {
                            VStack(alignment: .leading) {
                                Text(flag.key)
                                    .font(.subheadline.bold())
                                Text("Default: \(flag.defaultValue ? "ON" : "OFF")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button("Reset All Overrides", role: .destructive) {
                        FeatureFlagProvider.shared.removeAllOverrides()
                        refreshFlags()
                    }
                }

                Section("A/B Tests") {
                    ForEach(experiments) { experiment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(experiment.name)
                                .font(.subheadline.bold())
                            HStack {
                                Text("Variants: \(experiment.variants.joined(separator: ", "))")
                                Spacer()
                                Text("Traffic: \(Int(experiment.trafficPercentage * 100))%")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)

                            if let variant = ABTestEngine.variant(for: experiment.id) {
                                Text("Your variant: \(variant)")
                                    .font(.caption.bold())
                                    .foregroundStyle(.blue)
                            } else {
                                Text("Not enrolled")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section("Performance") {
                    NavigationLink("Performance Dashboard") {
                        PerformanceDashboardView()
                    }
                }

                Section("App Info") {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                    LabeledContent("Build", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—")
                    LabeledContent("Bundle ID", value: Bundle.main.bundleIdentifier ?? "—")
                }
            }
            .navigationTitle("Debug")
        }
    }

    private func refreshFlags() {
        flags = FeatureFlagProvider.shared.allFlags
    }
}
