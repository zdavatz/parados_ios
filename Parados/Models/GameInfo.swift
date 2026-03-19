import Foundation

struct GameVariant: Identifiable {
    let id = UUID()
    let filename: String
    let label: String
}

struct GameInfo: Identifiable {
    let id = UUID()
    let filename: String
    let title: String
    let players: String
    let description: String
    let variants: [GameVariant]

    init(filename: String, title: String, players: String, description: String, variants: [GameVariant] = []) {
        self.filename = filename
        self.title = title
        self.players = players
        self.description = description
        self.variants = variants
    }

    static func allGames() -> [GameInfo] {
        [
            GameInfo(
                filename: "kangaroo.html",
                title: "DUK — The Impatient Kangaroo",
                players: "1 Player · Puzzle",
                description: "A 21st century successor to Rushhour. Hop through the outback collecting goodies — with all kinds of different ways to play!",
                variants: [
                    GameVariant(filename: "kangaroo.html", label: "DE"),
                    GameVariant(filename: "kangaroo_en.html", label: "EN"),
                    GameVariant(filename: "kangaroo_jp.html", label: "JP"),
                    GameVariant(filename: "kangaroo_cn.html", label: "CN"),
                    GameVariant(filename: "kangaroo_ua.html", label: "UA")
                ]
            ),
            GameInfo(
                filename: "capovolto.html",
                title: "Capovolto",
                players: "2 Players · Strategy",
                description: "Othello on steroids! Area control on a random board, numbered discs and a flipping mechanism that invites all kinds of devious strategies."
            ),
            GameInfo(
                filename: "divided_loyalties.html",
                title: "Divided Loyalties",
                players: "2 Players · Strategy",
                description: "Connect 4 with 6 colours. Your colour is always loyal, your opponent's never is — and the other 4? Sometimes they are, sometimes they aren't."
            ),
            GameInfo(
                filename: "democracy_remote.html",
                title: "Democracy in Space",
                players: "2+ Players · Remote Multiplayer",
                description: "Based on the US Electoral College concept. Area majority culled to its essence — a gentle opening transforms into a nail biting race!"
            ),
            GameInfo(
                filename: "frankenstein.html",
                title: "Frankenstein — Where's that green elbow?",
                players: "1–4 Players · Memory",
                description: "Short, sweet, and frankly memorable! For 1–4 players, age 7 and up. Don't be surprised if the youngest player wins!"
            ),
            GameInfo(
                filename: "rainbow_blackjack.html",
                title: "Rainbow Blackjack",
                players: "2 Players · Strategy",
                description: "Colorful 21! Build 6 colored towers, trying to get as close to 21 as possible. Gray jokers add a devious twist.",
                variants: [
                    GameVariant(filename: "rainbow_blackjack.html", label: "Deutsch"),
                    GameVariant(filename: "rainbow_blackjack_en.html", label: "English"),
                    GameVariant(filename: "rainbow_blackjack_remote.html", label: "Remote")
                ]
            ),
            GameInfo(
                filename: "makalaina.html",
                title: "MAKA LAINA",
                players: "2 Players · Strategy",
                description: "The battle is on from the first turn! Plan from the get go, evolve your strategy — but stay flexible. Even a small shift can have consequences.",
                variants: [
                    GameVariant(filename: "makalaina.html", label: "Local"),
                    GameVariant(filename: "makalaina_remote.html", label: "Remote")
                ]
            )
        ]
    }

    static let allFilenames: [String] = [
        "index.html",
        "kangaroo.html", "kangaroo_en.html", "kangaroo_jp.html",
        "kangaroo_cn.html", "kangaroo_ua.html",
        "capovolto.html",
        "divided_loyalties.html",
        "democracy_remote.html",
        "frankenstein.html",
        "rainbow_blackjack.html", "rainbow_blackjack_en.html",
        "rainbow_blackjack_remote.html",
        "makalaina.html", "makalaina_remote.html"
    ]
}
