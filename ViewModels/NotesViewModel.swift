import AppKit
import Foundation

final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note]
    @Published var selectedNoteID: Note.ID?
    @Published var searchText = ""

    init(notes: [Note]) {
        self.notes = notes
        selectedNoteID = notes.first?.id
    }

    var selectedNote: Note? {
        notes.first { $0.id == selectedNoteID }
    }

    var filteredNotes: [Note] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            return notes
        }

        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(query)
                || note.body.localizedCaseInsensitiveContains(query)
        }
    }

    func createNote() {
        let note = Note(
            id: UUID(),
            title: "Untitled Note",
            body: "",
            lastEdited: Date(),
            folderID: nil
        )

        notes.insert(note, at: 0)
        selectedNoteID = note.id
    }

    func duplicate(_ note: Note) {
        let duplicate = Note(
            id: UUID(),
            title: "\(note.title) Copy",
            body: note.body,
            lastEdited: Date(),
            folderID: note.folderID
        )

        let insertionIndex = notes.firstIndex { $0.id == note.id }.map { $0 + 1 } ?? 0
        notes.insert(duplicate, at: insertionIndex)
        selectedNoteID = duplicate.id
    }

    func delete(_ note: Note) {
        notes.removeAll { $0.id == note.id }

        if selectedNoteID == note.id {
            selectedNoteID = notes.first?.id
        }
    }

    func share(_ note: Note) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("\(note.title)\n\n\(note.body)", forType: .string)
        #endif
    }
}
