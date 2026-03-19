import SwiftUI

struct GameCardView: View {
    let game: GameInfo
    let buttonColors: [Color]
    let onGameSelected: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(game.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "FFD700"))

            Text(game.players)
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "90A4AE"))

            Text(game.description)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "CFD8DC"))
                .lineSpacing(4)

            HStack(spacing: 8) {
                if game.variants.isEmpty {
                    GameButton(label: "Play", color: buttonColors[0]) {
                        onGameSelected(game.filename)
                    }
                } else {
                    ForEach(Array(game.variants.enumerated()), id: \.element.id) { index, variant in
                        GameButton(
                            label: variant.label,
                            color: buttonColors[index % buttonColors.count]
                        ) {
                            onGameSelected(variant.filename)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(16)
        .background(Color(hex: "37474F"))
        .cornerRadius(12)
    }
}

struct GameButton: View {
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color == Color(hex: "ff9800") ? Color(hex: "263238") : .white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(color)
                .cornerRadius(20)
        }
    }
}
