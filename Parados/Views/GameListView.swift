import SwiftUI

struct GameListView: View {
    @State private var isUpdating = false
    @State private var updateMessage: String?
    @State private var selectedGame: String?
    @State private var showMenu = false
    private let repository = GameRepository.shared
    private let games = GameInfo.allGames()

    private let buttonColors: [Color] = [
        Color(hex: "43a047"),
        Color(hex: "1e88e5"),
        Color(hex: "ff9800"),
        Color(hex: "e53935"),
        Color(hex: "8e24aa")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(games) { game in
                        GameCardView(
                            game: game,
                            buttonColors: buttonColors,
                            onGameSelected: { filename in
                                selectedGame = filename
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .background(Color(hex: "263238"))
            .scrollContentBackground(.hidden)
            .navigationTitle("PARADOS")
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
                isUpdating = false
                withAnimation {
                    updateMessage = updated > 0
                        ? "\(updated) Spiele aktualisiert"
                        : "Keine Updates verfügbar"
                }
            }
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
