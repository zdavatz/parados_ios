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

        for filename in GameInfo.allFilenames {
            guard let url = URL(string: "\(githubBaseURL)\(filename)") else { continue }

            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 15
                let (data, response) = try await URLSession.shared.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else { continue }

                let destURL = gamesDirectory.appendingPathComponent(filename)
                try data.write(to: destURL)
                updated += 1
            } catch {
                continue
            }
        }

        if updated > 0 {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastUpdateKey)
        }

        return updated
    }

    func lastUpdateTime() -> TimeInterval {
        return UserDefaults.standard.double(forKey: lastUpdateKey)
    }
}
