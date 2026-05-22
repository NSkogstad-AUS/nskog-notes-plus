import AppKit
import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isSidebarVisible = true
    @State private var window: NSWindow?
    private let minimumComfortableWidth: CGFloat = 1_040
    private let sidebarWidth: CGFloat = 220
    private let sidebarInset: CGFloat = 8
    private let sidebarGap: CGFloat = 8
    private let sidebarCornerRadius: CGFloat = 12
    private let toggleButtonSize: CGFloat = 28
    private let toggleButtonInset: CGFloat = 7

    var body: some View {
        ZStack(alignment: .topLeading) {
            HStack(spacing: 0) {
                sidebarPanel
                    .frame(width: isSidebarVisible ? sidebarColumnWidth : 0, alignment: .leading)
                    .frame(maxHeight: .infinity, alignment: .leading)
                    .clipped()

                NotesListView(viewModel: appViewModel.notesViewModel)
                    .frame(minWidth: 260, idealWidth: 320, maxWidth: 420, maxHeight: .infinity)

                Divider()

                detailView
                    .frame(minWidth: 360, maxWidth: .infinity, maxHeight: .infinity)
            }

            sidebarToggleButton
                .offset(x: sidebarToggleX, y: sidebarInset + toggleButtonInset)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .animation(.smooth(duration: 0.25), value: isSidebarVisible)
        .background(WindowAccessor { window = $0 })
        .frame(minWidth: 860, minHeight: 560)
    }

    private var sidebarColumnWidth: CGFloat {
        sidebarInset + sidebarWidth + sidebarGap
    }

    private var sidebarToggleX: CGFloat {
        if isSidebarVisible {
            sidebarInset + sidebarWidth - toggleButtonSize - toggleButtonInset
        } else {
            sidebarInset
        }
    }

    private var sidebarPanel: some View {
        SidebarView(folders: appViewModel.folders)
            .frame(width: sidebarWidth)
            .frame(maxHeight: .infinity)
            .background(.bar, in: RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            }
            .padding(.leading, sidebarInset)
            .padding(.vertical, sidebarInset)
            .padding(.trailing, sidebarGap)
    }

    private var sidebarToggleButton: some View {
        Button {
            toggleSidebar()
        } label: {
            Image(systemName: "sidebar.left")
                .font(.system(size: 14, weight: .medium))
                .frame(width: toggleButtonSize, height: toggleButtonSize)
                .contentShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
        .help("Toggle Sidebar")
        .accessibilityLabel("Toggle Sidebar")
    }

    @ViewBuilder
    private var detailView: some View {
        if let selectedNote = appViewModel.notesViewModel.selectedNote {
            EditorView(note: selectedNote)
        } else {
            EmptyStateView()
        }
    }

    private func toggleSidebar() {
        if isSidebarVisible {
            withAnimation(.smooth(duration: 0.25)) {
                isSidebarVisible = false
            }
            return
        }

        resizeWindowLeftForSidebarIfNeeded {
            withAnimation(.smooth(duration: 0.25)) {
                isSidebarVisible = true
            }
        }
    }

    private func resizeWindowLeftForSidebarIfNeeded(completion: @escaping () -> Void) {
        guard let window else {
            completion()
            return
        }

        let frame = window.frame

        guard frame.width < minimumComfortableWidth else {
            completion()
            return
        }

        let visibleFrame = window.screen?.visibleFrame ?? frame
        let rightEdge = frame.maxX
        let targetWidth = min(minimumComfortableWidth, rightEdge - visibleFrame.minX)

        guard targetWidth > frame.width else {
            completion()
            return
        }

        var targetFrame = frame
        targetFrame.size.width = targetWidth
        targetFrame.origin.x = rightEdge - targetWidth

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(targetFrame, display: true)
        } completionHandler: {
            completion()
        }
    }
}

private struct WindowAccessor: NSViewRepresentable {
    let onResolve: (NSWindow) -> Void
    private let minimumWindowSize = NSSize(width: 860, height: 560)

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.minSize = minimumWindowSize
                onResolve(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.minSize = minimumWindowSize
                onResolve(window)
            }
        }
    }
}
