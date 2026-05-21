import SwiftUI

struct SidebarView: View {
    let folders: [NoteFolder]

    var body: some View {
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
        .navigationTitle("Notes")
    }
}
