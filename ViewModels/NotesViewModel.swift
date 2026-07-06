import AppKit
import Foundation

final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] {
        didSet { updateFilteredNotes() }
    }
    @Published var selectedNoteID: Note.ID?
    @Published var searchText = "" {
        didSet { updateFilteredNotes() }
    }
    @Published private(set) var filteredNotes: [Note] = []

    init(notes: [Note]) {
        self.notes = notes
        selectedNoteID = notes.first?.id
        updateFilteredNotes()
    }

    var selectedNote: Note? {
        notes.first { $0.id == selectedNoteID }
    }

    private func updateFilteredNotes() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            filteredNotes = notes
            return
        }
        filteredNotes = notes.filter { note in
            note.title.localizedCaseInsensitiveContains(query)
                || note.body.localizedCaseInsensitiveContains(query)
        }
    }

    func createNote() {
        let note = Note(
            id: UUID(),
            title: "Untitled Note",
            body: "# Untitled Note\n\n",
            lastEdited: Date(),
            folderID: nil
        )

        notes.insert(note, at: 0)
        selectedNoteID = note.id
    }

    func updateSelectedNote(title: String, body: String) {
        guard let selectedNoteID else { return }
        updateNote(id: selectedNoteID, title: title, body: body)
    }

    func updateNote(id: Note.ID, title: String, body: String) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        let currentNote = notes[index]
        notes[index] = Note(
            id: currentNote.id,
            title: title,
            body: body,
            lastEdited: Date(),
            folderID: currentNote.folderID
        )
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
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("\(note.title)\n\n\(note.body)", forType: .string)
    }
}
