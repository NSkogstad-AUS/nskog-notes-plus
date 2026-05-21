import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    var body: some View {
        NavigationSplitView {
            SidebarView(folders: appViewModel.folders)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
        } content: {
            NotesListView(viewModel: appViewModel.notesViewModel)
                .navigationSplitViewColumnWidth(min: 260, ideal: 320, max: 420)
        } detail: {
            if let selectedNote = appViewModel.notesViewModel.selectedNote {
                EditorView(note: selectedNote)
            } else {
                EmptyStateView()
            }
        }
        .frame(minWidth: 860, minHeight: 560)
    }
}
