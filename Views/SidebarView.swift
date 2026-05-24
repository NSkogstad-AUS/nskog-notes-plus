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
    @State private var isCloseHovered = false
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
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.31, blue: 0.27))

                        Image(systemName: "xmark")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(Color(red: 0.45, green: 0.06, blue: 0.04))
                            .opacity(isCloseHovered ? 1 : 0)
                    }
                    .frame(width: 13, height: 13)
                }
                .buttonStyle(.plain)
                .onHover { isCloseHovered = $0 }
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

            ForEach(SettingsSection.visibleSections) { section in
                Button {
                    if section.isEnabled {
                        selectedSection = section
                    }
                } label: {
                    Label(section.title, systemImage: section.systemImage)
                        .font(.system(size: 12, weight: selectedSection == section && section.isEnabled ? .semibold : .regular))
                        .foregroundStyle(settingsSectionForeground(section))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(selectedSection == section && section.isEnabled ? Color(red: 0.82, green: 0.12, blue: 0.18) : Color.clear)
                        }
                }
                .buttonStyle(.plain)
                .disabled(!section.isEnabled)
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

    private func settingsSectionForeground(_ section: SettingsSection) -> Color {
        if !section.isEnabled {
            return .secondary.opacity(0.55)
        }

        return selectedSection == section ? .white : .primary
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
    case appearance
    case shortcuts
    case storage
    case extensions

    var id: String { rawValue }

    static var visibleSections: [SettingsSection] {
        [.general, .appearance, .shortcuts, .storage, .extensions]
    }

    var isEnabled: Bool {
        switch self {
        case .general, .appearance:
            return true
        case .shortcuts, .storage, .extensions:
            return false
        }
    }

    var title: String {
        switch self {
        case .general: "General"
        case .appearance: "Appearance"
        case .shortcuts: "Shortcuts"
        case .storage: "Storage"
        case .extensions: "Extensions"
        }
    }

    var systemImage: String {
        switch self {
        case .general: "gearshape"
        case .appearance: "paintbrush"
        case .shortcuts: "keyboard"
        case .storage: "externaldrive"
        case .extensions: "puzzlepiece.extension"
        }
    }

    var tint: Color {
        switch self {
        case .general: .gray
        case .appearance: .purple
        case .shortcuts: .indigo
        case .storage: .teal
        case .extensions: .orange
        }
    }

    var heroTitle: String {
        "\(title) Settings"
    }

    var heroDescription: String {
        switch self {
        case .general: "Control startup behavior, default folders, and app-wide preferences."
        case .appearance: "Customize theme, sidebar density, and editor presentation."
        case .shortcuts: "Review keyboard shortcuts and quick actions."
        case .storage: "Manage local storage, exports, backups, and note locations."
        case .extensions: "Manage future integrations and extension points."
        }
    }

    var groupTitle: String {
        switch self {
        case .general: "Application"
        case .appearance: "Theme"
        case .shortcuts: "Keyboard"
        case .storage: "Locations"
        case .extensions: "Extensions"
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
        case .appearance: "System Appearance"
        case .shortcuts: "Global Shortcuts"
        case .storage: "Local Notes"
        case .extensions: "Installed Extensions"
        }
    }

    private var primaryRowSubtitle: String {
        switch self {
        case .general: "Open Notes Plus automatically when you sign in."
        case .appearance: "Follow macOS or choose a fixed app appearance."
        case .shortcuts: "Set shortcuts for creating and finding notes."
        case .storage: "Store notes locally on this Mac."
        case .extensions: "Add integrations when extension support is available."
        }
    }

    private var primaryActionTitle: String? {
        switch self {
        case .general, .appearance, .shortcuts, .storage, .extensions: nil
        }
    }

    private var secondaryRowTitle: String {
        switch self {
        case .general: "Default Folder"
        case .appearance: "Sidebar Density"
        case .shortcuts: "Quick Actions"
        case .storage: "Backups"
        case .extensions: "Extension Permissions"
        }
    }

    private var secondaryRowSubtitle: String {
        switch self {
        case .general: "Choose where new notes are created."
        case .appearance: "Adjust spacing and row height in the sidebar."
        case .shortcuts: "Customize quick note commands."
        case .storage: "Configure automatic local backup behavior."
        case .extensions: "Control extension access to app features."
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
