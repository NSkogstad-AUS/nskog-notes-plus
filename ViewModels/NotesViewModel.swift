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
}
