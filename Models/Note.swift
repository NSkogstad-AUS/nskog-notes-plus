import Foundation

struct Note: Identifiable, Hashable {
    let id: UUID
    let title: String
    let body: String
    let lastEdited: Date
    let folderID: NoteFolder.ID?

    var preview: String {
        body
            .split(whereSeparator: \.isNewline)
            .first
            .map(String.init) ?? ""
    }
}
