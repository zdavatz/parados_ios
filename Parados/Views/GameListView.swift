import SwiftUI
import WebKit
import UIKit

struct GameListView: View {
    @State private var isUpdating = false
    @State private var updateMessage: String?
    @State private var selectedGame: String?
    @State private var menuReloadID = 0
    private let repository = GameRepository.shared

    var body: some View {
        NavigationStack {
            // The landing page is the SHARED index.html — the same file the
            // website + Android + desktop ship (Walter, 2026-06-03: "the
            // index.html has to be the same everywhere").  The update button
            // (toolbar) refreshes it from GitHub.  Taps on a game link open
            // the existing full-screen GameWebView; remote / external links
            // open in Safari.
            MenuWebView(reloadID: menuReloadID) { filename in
                selectedGame = filename
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .background(Color(hex: "263238"))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(hex: "263238"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if isUpdating {
                        ProgressView()
                            .tint(Color(hex: "FFD700"))
                    } else {
                        Menu {
                            Button(action: { updateGames() }) {
                                Label("Spiele aktualisieren", systemImage: "arrow.clockwise")
                            }
                        } label: {
                            Image("kangy")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 34, height: 34)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            .fullScreenCover(item: $selectedGame) { filename in
                GameWebView(filename: filename, onDismiss: {
                    selectedGame = nil
                })
            }
            .overlay {
                if let message = updateMessage {
                    VStack {
                        Spacer()
                        Text(message)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .cornerRadius(8)
                            .padding(.bottom, 32)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { updateMessage = nil }
                        }
                    }
                }
            }
            .onAppear {
                repository.ensureGamesInstalled()
            }
        }
        .tint(Color(hex: "FFD700"))
    }

    private func updateGames() {
        isUpdating = true
        Task {
            let updated = await repository.updateFromGithub()
            await MainActor.run {
                if updated > 0 {
                    WebViewStore.shared.clearCache()
                    menuReloadID += 1   // reload the menu so the refreshed index.html shows
                }
                isUpdating = false
                withAnimation {
                    updateMessage = updated > 0
                        ? "\(updated) Dateien aktualisiert"
                        : "Keine Updates verfügbar"
                }
            }
        }
    }
}

/// The landing page rendered from the shared, GitHub-updatable index.html.
/// A navigation delegate intercepts the in-page links: local game files open
/// the existing full-screen GameWebView; `*_remote.html` (PeerJS needs an
/// https origin) and external http(s) links open in Safari.  Kept in this
/// file (not a new one) so no Xcode project membership has to change.
struct MenuWebView: UIViewRepresentable {
    let reloadID: Int
    let onSelectGame: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelectGame: onSelectGame)
    }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0x26/255.0, green: 0x32/255.0, blue: 0x38/255.0, alpha: 1)

        context.coordinator.load(webView)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Re-load when the update button bumps reloadID, so the freshly
        // downloaded index.html replaces the one on screen.
        if context.coordinator.lastReloadID != reloadID {
            context.coordinator.lastReloadID = reloadID
            context.coordinator.load(webView)
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let onSelectGame: (String) -> Void
        var lastReloadID = 0

        init(onSelectGame: @escaping (String) -> Void) {
            self.onSelectGame = onSelectGame
        }

        func load(_ webView: WKWebView) {
            // Make sure the bundled games are unpacked before we point at one.
            GameRepository.shared.ensureGamesInstalled()
            let url = GameRepository.shared.gameFileURL(for: "index.html")
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Allow the initial index.html load and any non-tap navigation.
            guard navigationAction.navigationType == .linkActivated,
                  let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // External http(s) links (e.g. the GitHub footer link) → Safari.
            if let scheme = url.scheme, scheme == "http" || scheme == "https" {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
                return
            }

            let filename = url.lastPathComponent

            // Remote-multiplayer variants need a real https origin for
            // PeerJS/WebRTC — open the public site instead of the file.
            if filename.hasSuffix("_remote.html") {
                if let ext = URL(string: "https://game.ywesee.com/parados/\(filename)") {
                    UIApplication.shared.open(ext)
                }
                decisionHandler(.cancel)
                return
            }

            // Any other local page (a game or the Startpositionen tool) →
            // present it in the existing full-screen GameWebView.
            if !filename.isEmpty && filename != "index.html" {
                onSelectGame(filename)
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
