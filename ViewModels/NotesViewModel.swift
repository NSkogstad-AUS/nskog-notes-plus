import Foundation

final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note]
    @Published var selectedNoteID: Note.ID?

    init(notes: [Note]) {
        self.notes = notes
        selectedNoteID = notes.first?.id
    }

    var selectedNote: Note? {
        notes.first { $0.id == selectedNoteID }
    }
}
