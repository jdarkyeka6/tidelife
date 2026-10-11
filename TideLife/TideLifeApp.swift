import SwiftUI

@main
struct TideLifeApp: App {
    var body: some Scene {
        WindowGroup {
            EverafterGameView()
                .ignoresSafeArea()
                .preferredColorScheme(.dark)
        }
    }
}
