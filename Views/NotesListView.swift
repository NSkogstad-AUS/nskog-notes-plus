import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: NotesViewModel

    private let cardWidth: CGFloat = 184
    private let cardHeight: CGFloat = 136
    private let gridSpacing: CGFloat = 24

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 34) {
                header

                if let pinnedNote {
                    NoteSectionView(
                        title: "Pinned",
                        notes: [pinnedNote],
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        gridSpacing: gridSpacing,
                        selectedNoteID: $viewModel.selectedNoteID,
                        createNote: viewModel.createNote,
                        duplicateNote: viewModel.duplicate,
                        shareNote: viewModel.share,
                        deleteNote: viewModel.delete
                    )
                }

                ForEach(noteSections) { section in
                    NoteSectionView(
                        title: section.title,
                        notes: section.notes,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        gridSpacing: gridSpacing,
                        selectedNoteID: $viewModel.selectedNoteID,
                        createNote: viewModel.createNote,
                        duplicateNote: viewModel.duplicate,
                        shareNote: viewModel.share,
                        deleteNote: viewModel.delete
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Notes")
                .font(.system(size: 14, weight: .semibold))

            Text("\(viewModel.filteredNotes.count) notes")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
    }

    private var pinnedNote: Note? {
        viewModel.filteredNotes.first
    }

    private var unpinnedNotes: [Note] {
        Array(viewModel.filteredNotes.dropFirst())
    }

    private var noteSections: [NoteDateSection] {
        let groupedNotes = Dictionary(grouping: unpinnedNotes) { sectionTitle(for: $0.lastEdited) }

        return groupedNotes
            .map { title, notes in
                NoteDateSection(
                    title: title,
                    notes: notes.sorted { $0.lastEdited > $1.lastEdited },
                    sortDate: notes.map(\.lastEdited).max() ?? .distantPast
                )
            }
            .sorted { $0.sortDate > $1.sortDate }
    }

    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current

        if let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()),
           date >= thirtyDaysAgo {
            return "Previous 30 Days"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
}

private struct NoteSectionView: View {
    let title: String
    let notes: [Note]
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let gridSpacing: CGFloat
    @Binding var selectedNoteID: Note.ID?
    let createNote: () -> Void
    let duplicateNote: (Note) -> Void
    let shareNote: (Note) -> Void
    let deleteNote: (Note) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))

            LazyVGrid(columns: columns, alignment: .leading, spacing: 24) {
                ForEach(notes) { note in
                    NotePreviewItem(
                        note: note,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        isSelected: selectedNoteID == note.id,
                        createNote: createNote,
                        duplicateNote: { duplicateNote(note) },
                        shareNote: { shareNote(note) },
                        deleteNote: { deleteNote(note) },
                        action: { selectedNoteID = note.id }
                    )
                }
            }
        }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: cardWidth, maximum: cardWidth), spacing: gridSpacing, alignment: .top)]
    }
}

private struct NotePreviewItem: View {
    let note: Note
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let isSelected: Bool
    let createNote: () -> Void
    let duplicateNote: () -> Void
    let shareNote: () -> Void
    let deleteNote: () -> Void
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                NotePreviewCard(note: note)
                    .frame(width: cardWidth, height: cardHeight)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(isSelected ? Color.accentColor.opacity(0.55) : Color.clear, lineWidth: 2)
                    }

                VStack(spacing: 2) {
                    Text(note.title)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(note.lastEdited, format: .dateTime.day().month().year())
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .frame(width: cardWidth)
            }
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                action()
            } label: {
                Label("Open Note in New Window", systemImage: "rectangle.on.rectangle")
            }

            Divider()

            Button { } label: {
                Label("Unpin Note", systemImage: "pin.slash")
            }

            Button { } label: {
                Label("Lock Note", systemImage: "lock")
            }

            Divider()

            Button(action: createNote) {
                Label("New Note", systemImage: "square.and.pencil")
            }

            Button(action: duplicateNote) {
                Label("Duplicate Note", systemImage: "plus.square.on.square")
            }

            Divider()

            Button(action: shareNote) {
                Label("Share Note", systemImage: "square.and.arrow.up")
            }

            Divider()

            Menu {
                Button("Personal") { }
                Button("Work") { }
            } label: {
                Label("Move to", systemImage: "folder")
            }

            Divider()

            Button(role: .destructive, action: deleteNote) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

private struct NotePreviewCard: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(note.title)
                .font(.system(size: 8, weight: .semibold))
                .lineLimit(1)

            Text(previewText)
                .font(.system(size: 6.5))
                .lineSpacing(1)
                .foregroundStyle(.primary)
                .lineLimit(11)

            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
        }
    }

    private var previewText: String {
        note.body.isEmpty ? "Start writing..." : note.body
    }
}

private struct NoteDateSection: Identifiable {
    let title: String
    let notes: [Note]
    let sortDate: Date

    var id: String { title }
}
