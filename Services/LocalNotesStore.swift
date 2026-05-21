import Foundation

struct LocalNotesStore {
    func loadFolders() -> [NoteFolder] {
        [
            NoteFolder(id: UUID(uuidString: "3D7D59AB-6AF4-4CB5-8B28-7F58B93E1111")!, name: "Personal"),
            NoteFolder(id: UUID(uuidString: "3D7D59AB-6AF4-4CB5-8B28-7F58B93E2222")!, name: "Work")
        ]
    }

    func loadNotes() -> [Note] {
        let personalFolderID = UUID(uuidString: "3D7D59AB-6AF4-4CB5-8B28-7F58B93E1111")!
        let workFolderID = UUID(uuidString: "3D7D59AB-6AF4-4CB5-8B28-7F58B93E2222")!

        return [
            Note(
                id: UUID(uuidString: "7F58B93E-6AF4-4CB5-8B28-3D7D59AB1111")!,
                title: "Welcome",
                body: "A calm place for notes.\n\nThis is placeholder content for the initial app shell.",
                lastEdited: Date(timeIntervalSinceNow: -3600),
                folderID: personalFolderID
            ),
            Note(
                id: UUID(uuidString: "7F58B93E-6AF4-4CB5-8B28-3D7D59AB2222")!,
                title: "Project Ideas",
                body: "Keep the foundation small, fast, and easy to extend.",
                lastEdited: Date(timeIntervalSinceNow: -86400),
                folderID: workFolderID
            ),
            Note(
                id: UUID(uuidString: "7F58B93E-6AF4-4CB5-8B28-3D7D59AB3333")!,
                title: "Plain Text First",
                body: "Rich text and Markdown can come later. The first version should feel simple and native.",
                lastEdited: Date(timeIntervalSinceNow: -172800),
                folderID: nil
            )
        ]
    }
}
