import WebKit

class WebViewStore: ObservableObject {
    static let shared = WebViewStore()
    private var webViews: [String: WKWebView] = [:]

    func webView(for filename: String) -> WKWebView {
        if let existing = webViews[filename] {
            return existing
        }

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .black

        let repository = GameRepository.shared
        let fileURL = repository.gameFileURL(for: filename)
        let gamesDir = fileURL.deletingLastPathComponent()
        webView.loadFileURL(fileURL, allowingReadAccessTo: gamesDir)

        webViews[filename] = webView
        return webView
    }
}
