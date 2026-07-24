
import SwiftUI
import SwiftData

@main
struct BUILTApp: App {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: QuitProfile.self,
                CravingEntry.self,
                MotivationPhoto.self
            )
        } catch {
            fatalError("Unable to create SwiftData container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
