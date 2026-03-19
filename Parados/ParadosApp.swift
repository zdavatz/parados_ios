import SwiftUI

@main
struct ParadosApp: App {
    var body: some Scene {
        WindowGroup {
            GameListView()
                .preferredColorScheme(.dark)
        }
    }
}
