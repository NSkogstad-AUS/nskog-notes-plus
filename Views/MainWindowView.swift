import AppKit
import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var window: NSWindow?

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
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
        .navigationSplitViewStyle(.balanced)
        .animation(.smooth(duration: 0.25), value: columnVisibility)
        .background(WindowAccessor { window = $0 })
        .onChange(of: columnVisibility) { _, visibility in
            expandWindowLeftForSidebarIfNeeded(visibility)
        }
        .onAppear {
            expandWindowLeftForSidebarIfNeeded(columnVisibility)
        }
        .frame(minWidth: 860, minHeight: 560)
    }

    private func expandWindowLeftForSidebarIfNeeded(_ visibility: NavigationSplitViewVisibility) {
        guard shouldMakeRoomForSidebar(visibility), let window else {
            return
        }

        let minimumComfortableWidth: CGFloat = 1_040
        let frame = window.frame

        guard frame.width < minimumComfortableWidth else {
            return
        }

        let visibleFrame = window.screen?.visibleFrame ?? frame
        let rightEdge = frame.maxX
        let targetWidth = min(minimumComfortableWidth, rightEdge - visibleFrame.minX)

        guard targetWidth > frame.width else {
            return
        }

        var targetFrame = frame
        targetFrame.size.width = targetWidth
        targetFrame.origin.x = rightEdge - targetWidth

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(targetFrame, display: true)
        }
    }

    private func shouldMakeRoomForSidebar(_ visibility: NavigationSplitViewVisibility) -> Bool {
        visibility == .all || visibility == .automatic
    }
}

private struct WindowAccessor: NSViewRepresentable {
    let onResolve: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                onResolve(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                onResolve(window)
            }
        }
    }
}
