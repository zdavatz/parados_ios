import Foundation

struct GameVariant: Identifiable {
    let id = UUID()
    let filename: String
    let label: String
    let url: String?

    init(filename: String, label: String, url: String? = nil) {
        self.filename = filename
        self.label = label
        self.url = url
    }
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
                description: "The plan: to create a 21st century successor to the super-hit solo puzzle game Rushhour. Many players think that hopping through the outback collecting goodies is more fun than trying to shove your way through traffic? Another advantage — thanks to the program, there's all kinds of different ways to play:-)",
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
                description: "The classic game of Othello — on steroids! Add in area control on a random board, numbered discs and a flipping mechanism that is light years ahead of the original, inviting all kinds of devious strategies, and designed to make your brain go all sorts of places it hasn't been before:-)"
            ),
            GameInfo(
                filename: "divided_loyalties.html",
                title: "Divided Loyalties",
                players: "2 Players · Strategy",
                description: "Many turns are offensive AND defensive and each one may have long term consequences! It's connect 4, but with 6 colours. Your colour is always loyal to you, your opponent's never is... and the other 4? Sometimes they are, and sometimes they aren't. Tiles can even be loyal in one direction, AND disloyal in another! Not for the faint of heart...."
            ),
            GameInfo(
                filename: "democracy.html",
                title: "Democracy in Space",
                players: "2+ Players · Strategy",
                description: "Based on the concept of the US Electoral College (parliamentary systems also have it). Area majority culled to its essence. A gentle opening suddenly transforms into a nail biting race to the finish! The tie breaker condition needs to be kept in mind, but you won't know for a while if you'll need it this time....",
                variants: [
                    GameVariant(filename: "democracy.html", label: "Play"),
                    GameVariant(filename: "democracy_remote.html", label: "Remote", url: "https://game.ywesee.com/parados/democracy_remote.html")
                ]
            ),
            GameInfo(
                filename: "frankenstein.html",
                title: "Frankenstein — Where's that green elbow?",
                players: "1–4 Players · Memory",
                description: "This is even shorter and sweeter than Rainbow. For 1–4 players, it's a \"frankly memorable\" game (you'll get the pun when you play it). Like most of its colleagues here at Think Ahead, it is so much easier to play online. Age recommendation — 7 years and up. Don't be surprised if the youngest player wins:-))."
            ),
            GameInfo(
                filename: "rainbow_blackjack.html",
                title: "Rainbow Blackjack",
                players: "2 Players · Strategy",
                description: "Colorful 21! Two players build 6 colored towers, trying to get as close to 21 as possible — like Blackjack, but with colored stones. This game is easier to play than to describe:-) Arrange your stones in a grid, pick rows wisely, and announce just enough to keep your opponent guessing. Gray jokers add a devious twist...",
                variants: [
                    GameVariant(filename: "rainbow_blackjack.html", label: "Deutsch"),
                    GameVariant(filename: "rainbow_blackjack_en.html", label: "English"),
                    GameVariant(filename: "rainbow_blackjack_remote.html", label: "Remote", url: "https://game.ywesee.com/parados/rainbow_blackjack_remote.html")
                ]
            ),
            GameInfo(
                filename: "makalaina.html",
                title: "MAKA LAINA",
                players: "2 Players · Strategy",
                description: "It's the first turn and the battle is on! No time to get warmed up in MakaLaina:-) You need to be planning from the get go, evolving your long term strategy — but staying flexible. The constant influx of new discs means that even a small shift can have consequences...",
                variants: [
                    GameVariant(filename: "makalaina.html", label: "Play"),
                    GameVariant(filename: "makalaina_remote.html", label: "Remote", url: "https://game.ywesee.com/parados/makalaina_remote.html")
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
        "democracy.html", "democracy_remote.html",
        "frankenstein.html",
        "rainbow_blackjack.html", "rainbow_blackjack_en.html",
        "rainbow_blackjack_remote.html",
        "makalaina.html", "makalaina_remote.html"
    ]
}
