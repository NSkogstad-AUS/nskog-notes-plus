import AppKit
import SwiftUI

struct NotesListView: View {
    @ObservedObject var viewModel: NotesViewModel

    private let cardWidth: CGFloat = 184
    private let cardHeight: CGFloat = 136
    private let gridSpacing: CGFloat = 24

    @State private var noteSections: [NoteDateSection] = []

    var body: some View {
        let notes = viewModel.filteredNotes
        let pinned = notes.first

        ScrollView {
            VStack(alignment: .leading, spacing: 34) {
                if let pinned {
                    NoteSectionView(
                        title: "Pinned",
                        notes: [pinned],
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        gridSpacing: gridSpacing,
                        selectedNoteID: $viewModel.selectedNoteID,
                        viewModel: viewModel
                    )
                    .equatable()
                }

                ForEach(noteSections) { section in
                    NoteSectionView(
                        title: section.title,
                        notes: section.notes,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        gridSpacing: gridSpacing,
                        selectedNoteID: $viewModel.selectedNoteID,
                        viewModel: viewModel
                    )
                    .equatable()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 68)
            .padding(.bottom, 40)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onChange(of: viewModel.filteredNotes) { _, newNotes in
            noteSections = buildSections(from: newNotes)
        }
    }

    private func buildSections(from notes: [Note]) -> [NoteDateSection] {
        let unpinned = notes.dropFirst()
        let groupedNotes = Dictionary(grouping: unpinned) { sectionTitle(for: $0.lastEdited) }

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

    private static let calendar = Calendar.current
    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM"
        return f
    }()

    private func sectionTitle(for date: Date) -> String {
        if let thirtyDaysAgo = Self.calendar.date(byAdding: .day, value: -30, to: Date()),
           date >= thirtyDaysAgo {
            return "Previous 30 Days"
        }

        return Self.monthFormatter.string(from: date)
    }
}

private struct NoteSectionView: View, Equatable {
    let title: String
    let notes: [Note]
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let gridSpacing: CGFloat
    @Binding var selectedNoteID: Note.ID?
    let viewModel: NotesViewModel

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
                        selectedNoteID: $selectedNoteID,
                        viewModel: viewModel
                    )
                    .equatable()
                }
            }
        }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: cardWidth, maximum: cardWidth), spacing: gridSpacing, alignment: .top)]
    }

    static func == (lhs: NoteSectionView, rhs: NoteSectionView) -> Bool {
        lhs.title == rhs.title
            && lhs.notes == rhs.notes
            && lhs.cardWidth == rhs.cardWidth
            && lhs.cardHeight == rhs.cardHeight
            && lhs.gridSpacing == rhs.gridSpacing
            && lhs.selectedNoteID == rhs.selectedNoteID
    }
}

private struct NotePreviewItem: View, Equatable {
    let note: Note
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let isSelected: Bool
    @Binding var selectedNoteID: Note.ID?
    let viewModel: NotesViewModel

    var body: some View {
        Button(action: { selectedNoteID = note.id }) {
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
                selectedNoteID = note.id
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

            Button(action: viewModel.createNote) {
                Label("New Note", systemImage: "square.and.pencil")
            }

            Button(action: { viewModel.duplicate(note) }) {
                Label("Duplicate Note", systemImage: "plus.square.on.square")
            }

            Divider()

            Button(action: { viewModel.share(note) }) {
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

            Button(role: .destructive, action: { viewModel.delete(note) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    static func == (lhs: NotePreviewItem, rhs: NotePreviewItem) -> Bool {
        lhs.note == rhs.note
            && lhs.cardWidth == rhs.cardWidth
            && lhs.cardHeight == rhs.cardHeight
            && lhs.isSelected == rhs.isSelected
            && lhs.selectedNoteID == rhs.selectedNoteID
    }
}

private struct NotePreviewCard: View {
    @Environment(\.colorScheme) private var colorScheme
    let note: Note

    private var cardFillColor: Color {
        Color(nsColor: colorScheme == .dark ? .controlBackgroundColor : .textBackgroundColor)
    }

    private var cardStrokeColor: Color {
        Color(nsColor: .separatorColor).opacity(colorScheme == .dark ? 0.42 : 0.16)
    }

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
        .background(cardFillColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(cardStrokeColor, lineWidth: 1)
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
