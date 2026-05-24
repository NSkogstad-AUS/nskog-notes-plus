import SwiftUI

struct SidebarView: View {
    let folders: [NoteFolder]
    @State private var isSettingsPresented = false

    var body: some View {
        VStack(spacing: 0) {
            List {
                Section {
                    Label("All Notes", systemImage: "note.text")
                        .fontWeight(.medium)
                }

                Section("Folders") {
                    ForEach(folders) { folder in
                        Label(folder.name, systemImage: "folder")
                    }
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)

            Button {
                isSettingsPresented = true
            } label: {
                Label("Settings", systemImage: "gearshape")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.bottom, 10)
        }
        .navigationTitle("Notes")
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
    }
}

private struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: SettingsSection = .general
    private let settingsSidebarWidth: CGFloat = 188
    private let settingsSidebarCornerRadius: CGFloat = 12
    private let settingsSidebarInset: CGFloat = 8
    private let settingsSidebarTitlebarHeight: CGFloat = 44

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            settingsSidebar

            settingsDetail
        }
        .frame(width: 720, height: 450)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var settingsSidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Button {
                    dismiss()
                } label: {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.31, blue: 0.27))
                        .frame(width: 13, height: 13)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close Settings")

                Circle()
                    .fill(Color.gray.opacity(0.35))
                    .frame(width: 13, height: 13)

                Circle()
                    .fill(Color.gray.opacity(0.35))
                    .frame(width: 13, height: 13)
            }
            .padding(.top, 13)
            .padding(.leading, 16)
            .frame(height: settingsSidebarTitlebarHeight, alignment: .topLeading)

            ForEach(SettingsSection.allCases) { section in
                Button {
                    selectedSection = section
                } label: {
                    Label(section.title, systemImage: section.systemImage)
                        .font(.system(size: 12, weight: selectedSection == section ? .semibold : .regular))
                        .foregroundStyle(selectedSection == section ? .white : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selectedSection == section ? Color(red: 0.82, green: 0.12, blue: 0.18) : Color.clear)
                        }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .padding(.vertical, 1)
            }

            Spacer()
        }
        .frame(width: settingsSidebarWidth)
        .frame(maxHeight: .infinity)
        .background(Color(red: 0.976, green: 0.976, blue: 0.976), in: RoundedRectangle(cornerRadius: settingsSidebarCornerRadius, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: settingsSidebarCornerRadius, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
        .overlay {
            RoundedRectangle(cornerRadius: settingsSidebarCornerRadius, style: .continuous)
                .stroke(Color.white, lineWidth: 2)
        }
        .padding(.leading, settingsSidebarInset)
        .padding(.top, settingsSidebarInset)
        .padding(.bottom, settingsSidebarInset)
    }

    private var settingsDetail: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Button { } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.tertiary)
                .background(Circle().fill(Color(nsColor: .controlBackgroundColor)))

                Text(selectedSection.title)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()
            }

            SettingsHeroCard(section: selectedSection)

            Text(selectedSection.groupTitle)
                .font(.system(size: 13, weight: .semibold))
                .padding(.top, 4)

            VStack(spacing: 0) {
                ForEach(selectedSection.rows.indices, id: \.self) { index in
                    SettingsRow(row: selectedSection.rows[index])

                    if index < selectedSection.rows.count - 1 {
                        Divider()
                            .padding(.leading, 44)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.68))
            }

            Text(selectedSection.footerTitle)
                .font(.system(size: 13, weight: .semibold))
                .padding(.top, 4)

            SettingsRow(row: selectedSection.footerRow)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.68))
                }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct SettingsHeroCard: View {
    let section: SettingsSection

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: section.systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(section.tint)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(section.heroTitle)
                    .font(.system(size: 13, weight: .semibold))

                Text(section.heroDescription)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.68))
        }
    }
}

private struct SettingsRow: View {
    let row: SettingsRowModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: row.systemImage)
                .font(.system(size: 15))
                .foregroundStyle(row.tint)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.system(size: 13))

                Text(row.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let actionTitle = row.actionTitle {
                Button(actionTitle) { }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
    }
}

private enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case accounts
    case intelligence
    case behavior
    case appearance
    case editing
    case shortcuts
    case storage

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: "General"
        case .accounts: "Accounts"
        case .intelligence: "Intelligence"
        case .behavior: "Behavior"
        case .appearance: "Appearance"
        case .editing: "Editing"
        case .shortcuts: "Shortcuts"
        case .storage: "Storage"
        }
    }

    var systemImage: String {
        switch self {
        case .general: "gearshape"
        case .accounts: "person.crop.circle"
        case .intelligence: "sparkles"
        case .behavior: "slider.horizontal.3"
        case .appearance: "paintbrush"
        case .editing: "square.and.pencil"
        case .shortcuts: "keyboard"
        case .storage: "externaldrive"
        }
    }

    var tint: Color {
        switch self {
        case .general: .gray
        case .accounts: .blue
        case .intelligence: .red
        case .behavior: .orange
        case .appearance: .purple
        case .editing: .green
        case .shortcuts: .indigo
        case .storage: .teal
        }
    }

    var heroTitle: String {
        "\(title) Settings"
    }

    var heroDescription: String {
        switch self {
        case .general: "Control startup behavior, default folders, and app-wide preferences."
        case .accounts: "Manage connected accounts and sync preferences for your notes."
        case .intelligence: "Configure note assistance, summaries, and writing suggestions."
        case .behavior: "Adjust how notes open, select, sort, and respond to actions."
        case .appearance: "Customize theme, sidebar density, and editor presentation."
        case .editing: "Set writing defaults, text behavior, and editor preferences."
        case .shortcuts: "Review keyboard shortcuts and quick actions."
        case .storage: "Manage local storage, exports, backups, and note locations."
        }
    }

    var groupTitle: String {
        switch self {
        case .general: "Application"
        case .accounts: "Accounts"
        case .intelligence: "Agents"
        case .behavior: "Navigation"
        case .appearance: "Theme"
        case .editing: "Editor"
        case .shortcuts: "Keyboard"
        case .storage: "Locations"
        }
    }

    var rows: [SettingsRowModel] {
        [
            SettingsRowModel(title: primaryRowTitle, subtitle: primaryRowSubtitle, systemImage: systemImage, tint: tint, actionTitle: primaryActionTitle),
            SettingsRowModel(title: secondaryRowTitle, subtitle: secondaryRowSubtitle, systemImage: "chevron.left.forwardslash.chevron.right", tint: .secondary, actionTitle: nil)
        ]
    }

    var footerTitle: String {
        "Advanced"
    }

    var footerRow: SettingsRowModel {
        SettingsRowModel(
            title: "Permissions",
            subtitle: "Control access to app features and local note data.",
            systemImage: "lock",
            tint: .secondary,
            actionTitle: nil
        )
    }

    private var primaryRowTitle: String {
        switch self {
        case .general: "Launch at Login"
        case .accounts: "iCloud Account"
        case .intelligence: "Writing Assistant"
        case .behavior: "Default Note Selection"
        case .appearance: "System Appearance"
        case .editing: "Plain Text Editing"
        case .shortcuts: "Global Shortcuts"
        case .storage: "Local Notes"
        }
    }

    private var primaryRowSubtitle: String {
        switch self {
        case .general: "Open Notes Plus automatically when you sign in."
        case .accounts: "Connect an account for future sync features."
        case .intelligence: "Enable contextual help for note drafts and summaries."
        case .behavior: "Choose what appears when the app opens."
        case .appearance: "Follow macOS or choose a fixed app appearance."
        case .editing: "Keep note editing fast, local, and simple."
        case .shortcuts: "Set shortcuts for creating and finding notes."
        case .storage: "Store notes locally on this Mac."
        }
    }

    private var primaryActionTitle: String? {
        switch self {
        case .accounts, .intelligence: "Get"
        default: nil
        }
    }

    private var secondaryRowTitle: String {
        switch self {
        case .general: "Default Folder"
        case .accounts: "Account Privacy"
        case .intelligence: "Model Preferences"
        case .behavior: "List Sorting"
        case .appearance: "Sidebar Density"
        case .editing: "Markdown"
        case .shortcuts: "Quick Actions"
        case .storage: "Backups"
        }
    }

    private var secondaryRowSubtitle: String {
        switch self {
        case .general: "Choose where new notes are created."
        case .accounts: "Review account data and connection settings."
        case .intelligence: "Choose how assistance is shown in notes."
        case .behavior: "Sort notes by edit date, title, or folder."
        case .appearance: "Adjust spacing and row height in the sidebar."
        case .editing: "Enable lightweight Markdown conveniences."
        case .shortcuts: "Customize quick note commands."
        case .storage: "Configure automatic local backup behavior."
        }
    }
}

private struct SettingsRowModel: Identifiable {
    var id: String { title }
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let actionTitle: String?
}
