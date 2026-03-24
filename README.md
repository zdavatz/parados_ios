# Parados iOS

Parados is a collection of 7 original board games playable on your iPhone and iPad. All games are fully embedded and playable offline — no internet connection required.

## Games

- **DUK — The Impatient Kangaroo** (1 Player, Puzzle) — A puzzle game inspired by Rush Hour. Hop through the outback collecting goodies. Available in 5 languages (DE, EN, JP, CN, UA).
- **Capovolto** (2 Players, Strategy) — Othello reinvented with area control, numbered discs, and a new flipping mechanism on a random board.
- **Divided Loyalties** (2 Players, Strategy) — Connect 4 with 6 colours and shifting allegiances. Every move is both offensive and defensive.
- **Democracy in Space** (2+ Players, Strategy) — Area majority game inspired by the Electoral College concept. Also available as a remote multiplayer variant.
- **Frankenstein — Where's that green elbow?** (1–4 Players, Memory) — A quick memory game for ages 7 and up. Short, sweet, and surprisingly competitive.
- **Rainbow Blackjack** (2 Players, Strategy) — Build coloured towers to reach 21. Available in German and English, with a remote multiplayer variant.
- **MAKA LAINA** (2 Players, Strategy) — A fast-paced strategy game with constantly shifting disc placement. Also available as a remote multiplayer variant.

Three games offer optional remote multiplayer via Safari (`https://game.ywesee.com/parados/`) for cross-device PeerJS networking. If remote games show a black page in Safari, clear the Safari cache for `game.ywesee.com` (Settings > Safari > Advanced > Website Data).

### CSV Export & Import

Games with CSV export: all Kangaroo variants (DE/EN/JP/CN/UA), Frankenstein, Rainbow Blackjack (DE/EN/Remote), and MAKA LAINA (Local/Remote). Tapping the export button opens the iOS share sheet to save to Files, AirDrop, email, etc. Kangaroo (German) also supports CSV import for game replay.

## App Store Review Notes

Apple guideline 4.7.4 requires an index of non-embedded games. All games are bundled in the app binary; only the remote multiplayer variants load from external URLs:

| Game Name | Developer | URL |
|-----------|-----------|-----|
| Democracy in Space (Remote) | Think Ahead Games / ywesee GmbH | https://game.ywesee.com/parados/democracy_remote.html |
| Rainbow Blackjack (Remote) | Think Ahead Games / ywesee GmbH | https://game.ywesee.com/parados/rainbow_blackjack_remote.html |
| MAKA LAINA (Remote) | Think Ahead Games / ywesee GmbH | https://game.ywesee.com/parados/makalaina_remote.html |

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
