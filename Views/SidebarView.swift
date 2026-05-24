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
            SettingsPlaceholderView()
        }
    }
}

private struct SettingsPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.title2.weight(.semibold))

            Text("Settings will appear here.")
                .foregroundStyle(.secondary)
        }
        .frame(width: 320, alignment: .leading)
        .padding(24)
    }
}
