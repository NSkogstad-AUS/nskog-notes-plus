import AppKit
import SwiftUI

struct MainWindowView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isSidebarVisible = true
    @State private var sidebarProgress: CGFloat = 1
    private let sidebarWidth: CGFloat = 220
    private let sidebarInset: CGFloat = 8
    private let sidebarTopInset: CGFloat = 6
    private let sidebarGap: CGFloat = 8
    private let sidebarCornerRadius: CGFloat = 12
    private let sidebarTitlebarHeight: CGFloat = 44
    private let toggleButtonSize: CGFloat = 28
    private let toggleButtonInset: CGFloat = 7
    private let titlebarToggleX: CGFloat = 95
    private let titlebarControlTopInset: CGFloat = 12
    private let sidebarAnimationDuration: TimeInterval = 0.25

    var body: some View {
        ZStack(alignment: .topLeading) {
            sidebarPanel
                .frame(width: sidebarColumnWidth, alignment: .leading)
                .frame(maxHeight: .infinity, alignment: .leading)
                .offset(x: -sidebarColumnWidth * (1 - sidebarProgress))

            sidebarToggleButton
                .modifier(
                    SidebarTogglePosition(
                        progress: sidebarProgress,
                        sidebarColumnWidth: sidebarColumnWidth,
                        sidebarVisualRightEdge: sidebarInset + sidebarWidth,
                        dockedX: sidebarInset + sidebarWidth - toggleButtonSize - toggleButtonInset,
                        dockedY: sidebarTopInset + toggleButtonInset,
                        titlebarX: titlebarToggleX,
                        titlebarY: titlebarControlTopInset,
                        edgeInset: toggleButtonInset
                    )
                )
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

    private var sidebarAnimation: Animation {
        .linear(duration: sidebarAnimationDuration)
    }

    private var sidebarPanel: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: sidebarTitlebarHeight)

            SidebarView(folders: appViewModel.folders)
        }
            .frame(width: sidebarWidth)
            .frame(maxHeight: .infinity)
            .background(.bar, in: RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: sidebarCornerRadius, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            }
            .padding(.leading, sidebarInset)
            .padding(.top, sidebarTopInset)
            .padding(.bottom, sidebarInset)
            .padding(.trailing, sidebarGap)
    }

    private var sidebarToggleButton: some View {
        Button {
            toggleSidebar()
        } label: {
            Image(systemName: "sidebar.left")
                .font(.system(size: 14, weight: .medium))
                .frame(width: toggleButtonSize, height: toggleButtonSize)
                .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
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

    private func toggleSidebar() {
        if isSidebarVisible {
            closeSidebar()
            return
        }

        openSidebar()
    }

    private func openSidebar() {
        isSidebarVisible = true

        withAnimation(sidebarAnimation) {
            sidebarProgress = 1
        }
    }

    private func closeSidebar() {
        isSidebarVisible = false

        withAnimation(sidebarAnimation) {
            sidebarProgress = 0
        }
    }
}

private struct WindowAccessor: NSViewRepresentable {
    let onResolve: (NSWindow) -> Void
    private let minimumWindowSize = NSSize(width: 860, height: 560)
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
        moveTrafficLights(in: window)
    }

    private func moveTrafficLights(in window: NSWindow) {
        let buttonTypes: [(String, NSWindow.ButtonType)] = [
            ("close", .closeButton),
            ("miniaturize", .miniaturizeButton),
            ("zoom", .zoomButton)
        ]
        let buttons = buttonTypes.compactMap { key, type in
            window.standardWindowButton(type).map { (key, $0) }
        }

        guard buttons.count == buttonTypes.count else {
            return
        }

        let windowID = ObjectIdentifier(window)

        if Self.trafficLightBaseFrames[windowID] == nil {
            Self.trafficLightBaseFrames[windowID] = Dictionary(
                uniqueKeysWithValues: buttons.map { key, button in
                    (key, button.frame)
                }
            )
        }

        guard let baseFrames = Self.trafficLightBaseFrames[windowID] else {
            return
        }

        let xOffset: CGFloat = 5
        let yOffset: CGFloat = buttons.first?.1.superview?.isFlipped == true ? 4 : -4

        for (key, button) in buttons {
            guard let baseFrame = baseFrames[key] else {
                continue
            }

            button.setFrameOrigin(
                CGPoint(
                    x: baseFrame.origin.x + xOffset,
                    y: baseFrame.origin.y + yOffset
                )
            )
        }
    }
}

private struct SidebarTogglePosition: AnimatableModifier {
    var progress: CGFloat
    let sidebarColumnWidth: CGFloat
    let sidebarVisualRightEdge: CGFloat
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
        let edgeAttachedX = visibleRightEdge - edgeInset
        return min(dockedX, max(titlebarX, edgeAttachedX))
    }

    private var yOffset: CGFloat {
        titlebarY + (dockedY - titlebarY) * dockProgress
    }

    private var dockProgress: CGFloat {
        guard dockedX != titlebarX else {
            return 1
        }

        return min(max((xOffset - titlebarX) / (dockedX - titlebarX), 0), 1)
    }
}
