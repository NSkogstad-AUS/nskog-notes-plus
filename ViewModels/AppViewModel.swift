import Foundation

final class AppViewModel: ObservableObject {
    @Published private(set) var folders: [NoteFolder]
    @Published var notesViewModel: NotesViewModel

    private let notesStore: LocalNotesStore

    init(notesStore: LocalNotesStore = LocalNotesStore()) {
        self.notesStore = notesStore
        let notes = notesStore.loadNotes()

        folders = notesStore.loadFolders()
        notesViewModel = NotesViewModel(notes: notes)
    }
}
