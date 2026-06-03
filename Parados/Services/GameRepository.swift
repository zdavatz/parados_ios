import Foundation

class GameRepository {
    static let shared = GameRepository()

    private let fileManager = FileManager.default
    private let gamesDirectoryName = "games"
    private let prefsKey = "parados_prefs"
    private let assetsVersionKey = "assets_version"
    private let lastUpdateKey = "last_update"
    private let githubBaseURL = "https://raw.githubusercontent.com/zdavatz/parados/main/"

    private var gamesDirectory: URL {
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDir.appendingPathComponent(gamesDirectoryName)
    }

    func ensureGamesInstalled() {
        let currentVersion = Int(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1") ?? 1
        let installedVersion = UserDefaults.standard.integer(forKey: assetsVersionKey)

        if installedVersion >= currentVersion && fileManager.fileExists(atPath: gamesDirectory.path) {
            return
        }

        copyBundledGames()
        UserDefaults.standard.set(currentVersion, forKey: assetsVersionKey)
    }

    private func copyBundledGames() {
        try? fileManager.createDirectory(at: gamesDirectory, withIntermediateDirectories: true)

        guard let bundlePath = Bundle.main.path(forResource: "Games", ofType: nil) else { return }
        let bundleURL = URL(fileURLWithPath: bundlePath)

        guard let files = try? fileManager.contentsOfDirectory(atPath: bundlePath) else { return }
        for filename in files {
            let sourceURL = bundleURL.appendingPathComponent(filename)
            let destURL = gamesDirectory.appendingPathComponent(filename)
            try? fileManager.removeItem(at: destURL)
            try? fileManager.copyItem(at: sourceURL, to: destURL)
        }
    }

    func gameFileURL(for filename: String) -> URL {
        return gamesDirectory.appendingPathComponent(filename)
    }

    func updateFromGithub() async -> Int {
        var updated = 0
        // Start from the known set, then let the freshly-downloaded index.html
        // ADD any newly-linked games, so a brand-new game is fully OTA (Walter,
        // 2026-06-03): drop the file in the web repo + link it in index.html and
        // the next "Spiele aktualisieren" pulls it — no app update needed.
        var filenames = Set(GameInfo.allFilenames)

        if let html = await downloadAndSave("index.html") {
            updated += 1
            filenames.remove("index.html")
            for f in Self.linkedFiles(in: html) { filenames.insert(f) }
        }

        for filename in filenames {
            if await downloadAndSave(filename) != nil { updated += 1 }
        }

        if updated > 0 {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastUpdateKey)
        }
        return updated
    }

    /// Download one file from GitHub into the games dir. Returns its text body
    /// on success (so index.html can be parsed for links), nil otherwise.
    @discardableResult
    private func downloadAndSave(_ filename: String) async -> String? {
        guard let url = URL(string: "\(githubBaseURL)\(filename)") else { return nil }
        do {
            var request = URLRequest(url: url)
            request.timeoutInterval = 15
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else { return nil }
            try data.write(to: gamesDirectory.appendingPathComponent(filename))
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }

    /// Local game/tool files an index.html links to: href="X.html" / "X.csv"
    /// with no scheme and not absolute — so a new game linked on the website is
    /// fetched without an app update.
    static func linkedFiles(in html: String) -> [String] {
        var out: [String] = []
        let pattern = "href\\s*=\\s*\"([^\"]+\\.(?:html|csv))\""
        guard let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return out }
        let ns = html as NSString
        for m in re.matches(in: html, range: NSRange(location: 0, length: ns.length)) {
            let s = ns.substring(with: m.range(at: 1))
            if !s.contains("://") && !s.hasPrefix("/") && !s.hasPrefix("#") { out.append(s) }
        }
        return out
    }

    func lastUpdateTime() -> TimeInterval {
        return UserDefaults.standard.double(forKey: lastUpdateKey)
    }
}
