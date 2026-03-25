# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Parados Games for iOS — a SwiftUI WebView container app that hosts HTML/JavaScript board games. iOS port of the Android version at `../parados_android`. Licensed under GPLv3.

## Build & Run

Project is generated with XcodeGen from `project.yml`.

```bash
# Regenerate Xcode project after changing project.yml
xcodegen generate

# Build for simulator
xcodebuild -scheme Parados -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Build and install on device
xcodebuild -scheme Parados -destination 'generic/platform=iOS' -allowProvisioningUpdates build
xcrun devicectl device install app --device DEVICE_ID path/to/Parados.app

# Archive and upload to App Store Connect (pure CLI, no Xcode GUI needed)
xcodebuild -scheme Parados -destination 'generic/platform=iOS' -allowProvisioningUpdates archive -archivePath /tmp/Parados.xcarchive
xcodebuild -exportArchive -archivePath /tmp/Parados.xcarchive -exportPath /tmp/ParadosUpload -exportOptionsPlist /tmp/exportOptions.plist -allowProvisioningUpdates

# exportOptions.plist for App Store upload:
# <?xml version="1.0" encoding="UTF-8"?>
# <plist version="1.0"><dict>
#   <key>method</key><string>app-store-connect</string>
#   <key>destination</key><string>upload</string>
#   <key>teamID</key><string>4B37356EGR</string>
#   <key>uploadSymbols</key><true/>
# </dict></plist>

# Open in Xcode
open Parados.xcodeproj
```

Bundle ID: `com.ywesee.parados` | Team: `4B37356EGR` | Min iOS: 16.0 | No external dependencies.

## Architecture

SwiftUI app with 2 screens, no third-party dependencies:

- **GameListView** → NavigationStack with ScrollView of game cards. Kangaroo icon in top-right opens menu with "Spiele aktualisieren" (update from GitHub).
- **GameWebView** → Full-screen WKWebView loading local HTML game files. Back button auto-hides after 3s. Swipe-from-left-edge gesture to dismiss.
- **WebViewStore** → Singleton cache that keeps WKWebView instances alive per game, so game state is preserved when navigating back to the menu and returning. Cache is cleared after GitHub updates so refreshed HTML files take effect immediately.

Key files:
- `Parados/Models/GameInfo.swift` — Game metadata, variant definitions (with optional `url` for remote play via Safari), and list of all filenames for GitHub sync
- `Parados/Services/GameRepository.swift` — Copies bundled games from app bundle to Documents on first launch, handles GitHub updates
- `Parados/Services/WebViewStore.swift` — Caches WKWebView instances per game filename to preserve game state; includes `WebViewBridge` for CSV export (share sheet via `WKScriptMessageHandler`), CSV import (file picker via `WKUIDelegate`), and JS alert/confirm dialogs
- `Parados/Views/GameListView.swift` — Main screen with game cards + Color hex extension
- `Parados/Views/GameCardView.swift` — Card component with colored variant buttons; variants with `url` open in Safari via `https://game.ywesee.com/parados/`
- `Parados/Views/GameWebView.swift` — WKWebView wrapper with gesture handling

## Game Assets

17 HTML game files + 1 CSV in `Parados/Resources/Games/` (bundled as folder reference). Games are self-contained HTML/JavaScript — all game logic lives in the HTML files, not in Swift code. Games are also downloadable from `https://raw.githubusercontent.com/zdavatz/parados/main/`.

## Screenshots

App screenshots are in the `Screenshots/` directory, showing game list views, individual games, and iPad layout.

## Design

Dark theme: background `#263238`, cards `#37474F`, gold accent `#FFD700`, button colors cycle through green/blue/orange/red/purple. Kangaroo app icon on cream background.

## App Store Review

Apple guideline 4.7.4 requires an index of non-embedded games submitted with each review. All games are bundled in the binary; only 3 remote multiplayer variants load external URLs (`democracy_remote.html`, `rainbow_blackjack_remote.html`, `makalaina_remote.html` via `https://game.ywesee.com/parados/`). The index must be included in the **Review Notes** field in App Store Connect for every submission. Developer for all games: Think Ahead Games / ywesee GmbH.

Apple guideline 2.1(a) requires the App Store description to list all games with descriptions. See README.md for the full game descriptions.

## Swift–JS Bridge

WKWebView doesn't natively support `<a download>` (blob URLs) or JS `alert()`/`confirm()`. The `WebViewBridge` class in `WebViewStore.swift` handles this:

- **CSV Export**: Injected JS (`WKUserScript` at document start) intercepts `HTMLAnchorElement.click()` on blob download links and routes CSV content to Swift via `WKScriptMessageHandler`. Swift writes a temp file and presents `UIActivityViewController` (share sheet).
- **CSV Import**: Setting `WKUIDelegate` on the webView enables `<input type="file">` to trigger the native iOS file picker. Used by kangaroo.html's replay feature.
- **JS Alerts/Confirms**: Forwarded to native `UIAlertController` so games can show dialogs (e.g., "no data to export").

The bridge operates at the WebView level — no HTML game files are modified, so "Spiele aktualisieren" (GitHub updates) continues to work.

## Troubleshooting

- **Remote games show black page in Safari**: Clear Safari cache for `game.ywesee.com` (Settings > Safari > Advanced > Website Data). The remote HTML files use PeerJS from CDN (`unpkg.com`, `cdnjs.cloudflare.com`) and Safari may cache stale versions.
