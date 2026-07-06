import AppKit
import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.colorScheme) private var colorScheme
    @State private var isSidebarVisible = true
    @State private var sidebarProgress: CGFloat = 1
    @State private var areTrafficLightsHovered = false
    private let sidebarWidth: CGFloat = 220
    private let sidebarInset: CGFloat = 8
    private let sidebarTopInset: CGFloat = 6
    private let sidebarGap: CGFloat = 8
    private let sidebarCornerRadius: CGFloat = 12
    private let sidebarTitlebarHeight: CGFloat = 44
    private let toggleButtonSize: CGFloat = 38
    private let toggleButtonInset: CGFloat = 6
    private let titlebarToggleX: CGFloat = 88
    private let titlebarControlTopInset: CGFloat = 7
    private let titlebarTrailingInset: CGFloat = 12
    private let titlebarActionHeight: CGFloat = 36
    private let titlebarActionWidth: CGFloat = 70
    private let titlebarSearchWidth: CGFloat = 328
    private let trafficLightSize: CGFloat = 13
    private let trafficLightGap: CGFloat = 8
    private let trafficLightLeading: CGFloat = 20
    private let trafficLightTop: CGFloat = 20
    private let sidebarOpenAnimation: Animation = .linear(duration: 0.2)
    private let sidebarCloseAnimation: Animation = .linear(duration: 0.16)

    var body: some View {
        ZStack(alignment: .topLeading) {
            notesOverview
                .padding(.leading, sidebarColumnWidth * sidebarProgress)

            sidebarPanel
                .frame(width: sidebarColumnWidth, alignment: .leading)
                .frame(maxHeight: .infinity, alignment: .leading)
                .offset(x: -sidebarColumnWidth * (1 - sidebarProgress))

            trafficLights
                .padding(.leading, trafficLightLeading)
                .padding(.top, trafficLightTop)

            sidebarToggleButton
                .modifier(
                    SidebarTogglePosition(
                        progress: sidebarProgress,
                        sidebarColumnWidth: sidebarColumnWidth,
                        sidebarVisualRightEdge: sidebarInset + sidebarWidth,
                        buttonSize: toggleButtonSize,
                        dockedX: sidebarInset + sidebarWidth - toggleButtonSize - toggleButtonInset,
                        dockedY: sidebarTopInset + toggleButtonInset,
                        titlebarX: titlebarToggleX,
                        titlebarY: titlebarControlTopInset,
                        edgeInset: toggleButtonInset
                    )
                )

            notesHeader
                .modifier(
                    NotesHeaderPosition(
                        progress: sidebarProgress,
                        sidebarColumnWidth: sidebarColumnWidth,
                        sidebarVisualRightEdge: sidebarInset + sidebarWidth,
                        toggleButtonSize: toggleButtonSize,
                        toggleInset: toggleButtonInset,
                        dockedToggleX: sidebarInset + sidebarWidth - toggleButtonSize - toggleButtonInset,
                        titlebarToggleX: titlebarToggleX,
                        yOffset: sidebarToggleTopInset + 2,
                        collapsedGap: 18,
                        expandedGap: 28
                    )
                )

            titlebarActions
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, sidebarToggleTopInset)
                .padding(.trailing, titlebarTrailingInset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(nsColor: .windowBackgroundColor))
        .ignoresSafeArea(.container, edges: .top)
        .background(WindowAccessor { _ in })
        .frame(minWidth: 860, minHeight: 560)
    }

    private var sidebarColumnWidth: CGFloat {
        sidebarInset + sidebarWidth + sidebarGap
    }

    private var toggleButtonCornerRadius: CGFloat {
        isSidebarVisible ? 10 : toggleButtonSize / 2
    }

    private var toggleButtonFillColor: Color {
        isSidebarVisible ? Color(nsColor: .controlColor).opacity(0.72) : Color(nsColor: .controlBackgroundColor)
    }

    private var toggleButtonPrimaryShadowOpacity: Double {
        isSidebarVisible ? 0.08 : 0.10
    }

    private var toggleButtonPrimaryShadowRadius: CGFloat {
        isSidebarVisible ? 8 : 14
    }

    private var toggleButtonPrimaryShadowY: CGFloat {
        isSidebarVisible ? 2 : 4
    }

    private var sidebarToggleTopInset: CGFloat {
        sidebarTopInset + toggleButtonInset
    }

    private var sidebarPanelFillColor: Color {
        Color(nsColor: colorScheme == .dark ? .controlBackgroundColor : .windowBackgroundColor)
    }

    private var sidebarPanelStrokeColor: Color {
        Color(nsColor: .separatorColor).opacity(colorScheme == .dark ? 0.38 : 0.14)
    }

    private var sidebarPanel: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: sidebarTitlebarHeight)

            SidebarView(folders: appViewModel.folders)
        }
        .frame(width: sidebarWidth)
        .frame(maxHeight: .infinity)
        .background(sidebarPanelFillColor, in: RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous))
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.24 : 0.08), radius: 8, x: 0, y: 2)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.14 : 0.05), radius: 4, x: 0, y: 1)
        .overlay {
            RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous)
                .stroke(sidebarPanelStrokeColor, lineWidth: 1)
        }
        .padding(.leading, sidebarInset)
        .padding(.top, sidebarTopInset)
        .padding(.bottom, sidebarInset)
        .padding(.trailing, sidebarGap)
    }

    private var notesOverview: some View {
        NotesListView(viewModel: appViewModel.notesViewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var notesHeader: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("Notes")
                .font(.system(size: 14, weight: .semibold))

            NotesCountText(notesViewModel: appViewModel.notesViewModel)
        }
    }

    private var sidebarToggleButton: some View {
        Button {
            toggleSidebar()
        } label: {
            Image(systemName: "sidebar.left")
                .font(.system(size: 16, weight: .regular))
                .frame(width: toggleButtonSize, height: toggleButtonSize)
                .contentShape(RoundedRectangle(cornerRadius: toggleButtonCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
        .background {
            RoundedRectangle(cornerRadius: toggleButtonCornerRadius, style: .continuous)
                .fill(toggleButtonFillColor)
                .shadow(color: .black.opacity(toggleButtonPrimaryShadowOpacity), radius: toggleButtonPrimaryShadowRadius, x: 0, y: toggleButtonPrimaryShadowY)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
        }
        .overlay {
            RoundedRectangle(cornerRadius: toggleButtonCornerRadius, style: .continuous)
                .stroke(.white.opacity(0.45), lineWidth: 1)
        }
        .help("Toggle Sidebar")
        .accessibilityLabel("Toggle Sidebar")
    }

    private var trafficLights: some View {
        HStack(spacing: trafficLightGap) {
            TrafficLightButton(
                color: Color(red: 1.0, green: 0.31, blue: 0.27),
                symbolName: "xmark",
                symbolColor: Color(red: 0.45, green: 0.06, blue: 0.04),
                isHovered: areTrafficLightsHovered,
                accessibilityLabel: "Close"
            ) {
                NSApplication.shared.keyWindow?.performClose(nil)
            }

            TrafficLightButton(
                color: Color(red: 1.0, green: 0.74, blue: 0.12),
                symbolName: "minus",
                symbolColor: Color(red: 0.52, green: 0.33, blue: 0.02),
                isHovered: areTrafficLightsHovered,
                accessibilityLabel: "Minimize"
            ) {
                NSApplication.shared.keyWindow?.miniaturize(nil)
            }

            TrafficLightButton(
                color: Color(red: 0.20, green: 0.78, blue: 0.35),
                symbolName: "arrow.up.left.and.arrow.down.right",
                symbolColor: Color(red: 0.04, green: 0.36, blue: 0.12),
                isHovered: areTrafficLightsHovered,
                accessibilityLabel: "Zoom"
            ) {
                NSApplication.shared.keyWindow?.zoom(nil)
            }
        }
        .contentShape(Rectangle())
        .onHover { areTrafficLightsHovered = $0 }
    }

    private var titlebarActions: some View {
        HStack(spacing: 34) {
            HStack(spacing: 0) {
                Menu {
                    Button("New Note") {
                        appViewModel.notesViewModel.createNote()
                    }

                    Divider()

                    Button("Clear Search") {
                        appViewModel.notesViewModel.searchText = ""
                    }
                    .disabled(appViewModel.notesViewModel.searchText.isEmpty)
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: titlebarActionWidth / 2, height: titlebarActionHeight)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .buttonStyle(.plain)
                .help("More")
                .accessibilityLabel("More")

                Button {
                    appViewModel.notesViewModel.createNote()
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 16, weight: .regular))
                        .frame(width: titlebarActionWidth / 2, height: titlebarActionHeight)
                }
                .buttonStyle(.plain)
                .help("New Note")
                .accessibilityLabel("New Note")
            }
            .frame(width: titlebarActionWidth, height: titlebarActionHeight)
            .foregroundStyle(.primary)
            .background {
                Capsule()
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.95))
                    .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
            }

            HStack(spacing: 7) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)

                TextField("Search", text: $appViewModel.notesViewModel.searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .regular))
            }
            .padding(.horizontal, 14)
            .frame(width: titlebarSearchWidth, height: titlebarActionHeight)
            .background {
                Capsule()
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.95))
                    .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
            }
        }
    }

    private func toggleSidebar() {
        if isSidebarVisible {
            closeSidebar()
            return
        }

        openSidebar()
    }

    private func openSidebar() {
        isSidebarVisible = true

        withAnimation(sidebarOpenAnimation) {
            sidebarProgress = 1
        }
    }

    private func closeSidebar() {
        isSidebarVisible = false

        withAnimation(sidebarCloseAnimation) {
            sidebarProgress = 0
        }
    }
}

private struct WindowAccessor: NSViewRepresentable {
    let onResolve: (NSWindow) -> Void
    private let minimumWindowSize = NSSize(width: 860, height: 560)
    private let trafficLightXOffset: CGFloat = 10
    private let trafficLightYOffset: CGFloat = 10
    private static var trafficLightBaseFrames: [ObjectIdentifier: [String: CGRect]] = [:]

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                configure(window)
                window.minSize = minimumWindowSize
                onResolve(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let window = nsView.window {
                configure(window)
                window.minSize = minimumWindowSize
                onResolve(window)
            }
        }
    }

    private func configure(_ window: NSWindow) {
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.isMovableByWindowBackground = true
        hideNativeTrafficLights(in: window)
    }

    private func hideNativeTrafficLights(in window: NSWindow) {
        let buttonTypes: [NSWindow.ButtonType] = [.closeButton, .miniaturizeButton, .zoomButton]

        for buttonType in buttonTypes {
            window.standardWindowButton(buttonType)?.isHidden = true
        }
    }
}

private struct TrafficLightButton: View {
    let color: Color
    let symbolName: String
    let symbolColor: Color
    let isHovered: Bool
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)

                Image(systemName: symbolName)
                    .font(.system(size: symbolName == "minus" ? 7 : 6, weight: .bold))
                    .foregroundStyle(symbolColor)
                    .opacity(isHovered ? 1 : 0)
            }
            .frame(width: 13, height: 13)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct SidebarTogglePosition: AnimatableModifier {
    var progress: CGFloat
    let sidebarColumnWidth: CGFloat
    let sidebarVisualRightEdge: CGFloat
    let buttonSize: CGFloat
    let dockedX: CGFloat
    let dockedY: CGFloat
    let titlebarX: CGFloat
    let titlebarY: CGFloat
    let edgeInset: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.offset(x: xOffset, y: yOffset)
    }

    private var xOffset: CGFloat {
        let visibleRightEdge = sidebarVisualRightEdge - sidebarColumnWidth * (1 - progress)
        let edgeAttachedX = visibleRightEdge - buttonSize - edgeInset
        return min(dockedX, max(titlebarX, edgeAttachedX))
    }

    private var yOffset: CGFloat {
        dockedY
    }
}

private struct NotesCountText: View {
    @ObservedObject var notesViewModel: NotesViewModel

    var body: some View {
        Text("\(notesViewModel.filteredNotes.count) notes")
            .font(.system(size: 11))
            .foregroundStyle(.secondary)
    }
}

private struct NotesHeaderPosition: AnimatableModifier {
    var progress: CGFloat
    let sidebarColumnWidth: CGFloat
    let sidebarVisualRightEdge: CGFloat
    let toggleButtonSize: CGFloat
    let toggleInset: CGFloat
    let dockedToggleX: CGFloat
    let titlebarToggleX: CGFloat
    let yOffset: CGFloat
    let collapsedGap: CGFloat
    let expandedGap: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        content.offset(x: xOffset, y: yOffset)
    }

    private var xOffset: CGFloat {
        let visibleRightEdge = sidebarVisualRightEdge - sidebarColumnWidth * (1 - progress)
        let edgeAttachedToggleX = visibleRightEdge - toggleButtonSize - toggleInset
        let toggleX = min(dockedToggleX, max(titlebarToggleX, edgeAttachedToggleX))
        let gap = collapsedGap + (expandedGap - collapsedGap) * progress
        return toggleX + toggleButtonSize + gap
    }
}
