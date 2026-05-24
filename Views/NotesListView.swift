import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: NotesViewModel

    var body: some View {
        List(selection: $viewModel.selectedNoteID) {
            ForEach(viewModel.filteredNotes) { note in
                NoteRow(note: note)
                    .tag(note.id)
            }
        }
        .listStyle(.plain)
        .navigationTitle("All Notes")
    }
}

private struct NoteRow: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(alignment: .firstTextBaseline) {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)

                Spacer(minLength: 12)

                Text(note.lastEdited, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(note.preview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 6)
    }
}
