# Parados iOS

Parados Games for iOS — a collection of HTML/JavaScript board games in a native SwiftUI shell.

## Games

- **DUK — The Impatient Kangaroo** (1 Player, Puzzle) — DE, EN, JP, CN, UA
- **Capovolto** (2 Players, Strategy)
- **Divided Loyalties** (2 Players, Strategy)
- **Democracy in Space** (2+ Players, Strategy) — Play, Remote
- **Frankenstein — Where's that green elbow?** (1–4 Players, Memory)
- **Rainbow Blackjack** (2 Players, Strategy) — Deutsch, English, Remote
- **MAKA LAINA** (2 Players, Strategy) — Play, Remote

Remote multiplayer variants open in Safari via `https://game.ywesee.com/parados/` for cross-device PeerJS networking. If remote games show a black page in Safari, clear the Safari cache for `game.ywesee.com` (Settings > Safari > Advanced > Website Data).

## Screenshots

| Game List (top) | Game List (bottom) | MAKA LAINA |
|---|---|---|
| ![Game List Top](Screenshots/01_game_list_top.png) | ![Game List Bottom](Screenshots/02_game_list_bottom.png) | ![MAKA LAINA](Screenshots/03_game_list_maka.png) |

| Kangaroo | Kangaroo Game | Capovolto |
|---|---|---|
| ![Kangaroo](Screenshots/03_kangaroo.png) | ![Kangaroo Game](Screenshots/04_kangaroo_game.png) | ![Capovolto](Screenshots/04_capovolto.png) |

| Frankenstein | Frankenstein Game | Rainbow Blackjack |
|---|---|---|
| ![Frankenstein](Screenshots/05_frankenstein.png) | ![Frankenstein Game](Screenshots/06_frankenstein_game.png) | ![Rainbow Blackjack](Screenshots/06_rainbow_blackjack.png) |

| iPad Game List |
|---|
| ![iPad](Screenshots/ipad_01_game_list.png) |

## Requirements

- iOS 16.0+
- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

## Build

```bash
xcodegen generate
open Parados.xcodeproj
```

## License

[GPLv3](LICENSE)
