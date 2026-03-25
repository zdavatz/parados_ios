import UIKit
import WebKit

class WebViewStore: ObservableObject {
    static let shared = WebViewStore()
    private var webViews: [String: WKWebView] = [:]
    private let bridge = WebViewBridge()

    func clearCache() {
        webViews.removeAll()
    }

    func webView(for filename: String) -> WKWebView {
        if let existing = webViews[filename] {
            return existing
        }

        let config = WKWebViewConfiguration()
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")

        // Register message handlers for CSV export
        let contentController = config.userContentController
        contentController.add(bridge, name: "csvExport")

        // Inject JS that intercepts <a download> clicks and routes through the bridge
        let script = WKUserScript(source: WebViewBridge.injectedJavaScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        contentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.uiDelegate = bridge

        let repository = GameRepository.shared
        let fileURL = repository.gameFileURL(for: filename)
        let gamesDir = fileURL.deletingLastPathComponent()
        webView.loadFileURL(fileURL, allowingReadAccessTo: gamesDir)

        webViews[filename] = webView
        return webView
    }
}

// MARK: - WebViewBridge handles CSV export and file input

class WebViewBridge: NSObject, WKScriptMessageHandler, WKUIDelegate {

    // JavaScript injected at document start to intercept blob download links
    static let injectedJavaScript = """
    (function() {
        // Override createElement to intercept <a download> pattern
        var _origClick = HTMLAnchorElement.prototype.click;
        HTMLAnchorElement.prototype.click = function() {
            if (this.hasAttribute('download') && this.href && this.href.startsWith('blob:')) {
                var filename = this.getAttribute('download') || 'export.csv';
                // Read the blob content
                fetch(this.href).then(function(r) { return r.text(); }).then(function(text) {
                    window.webkit.messageHandlers.csvExport.postMessage({
                        filename: filename,
                        content: text
                    });
                });
                return;
            }
            _origClick.call(this);
        };
    })();
    """;

    // MARK: - WKScriptMessageHandler (CSV Export)

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "csvExport",
              let body = message.body as? [String: Any],
              let content = body["content"] as? String,
              let filename = body["filename"] as? String else {
            return
        }

        // Write CSV to a temp file and present share sheet
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write CSV temp file: \(error)")
            return
        }

        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = scene.windows.first?.rootViewController else {
                return
            }
            // Find the topmost presented view controller
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            // iPad popover
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = topVC.view
                popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            topVC.present(activityVC, animated: true)
        }
    }

    // MARK: - WKUIDelegate

    // Setting uiDelegate enables <input type="file"> to work in WKWebView on iOS.
    // No runOpenPanelWith needed — iOS handles the file picker natively.

    // Alert support (some games use alert())
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else {
            completionHandler()
            return
        }
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        topVC.present(alert, animated: true)
    }

    // Confirm support
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.windows.first?.rootViewController else {
            completionHandler(false)
            return
        }
        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        alert.addAction(UIAlertAction(title: "Abbrechen", style: .cancel) { _ in completionHandler(false) })
        topVC.present(alert, animated: true)
    }
}
