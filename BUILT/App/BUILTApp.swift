import SwiftUI
import SwiftData

@main
struct BUILTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    private var appDelegate

    @StateObject
    private var storeManager = StoreManager()

    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: QuitProfile.self,
                CravingEntry.self,
                MotivationPhoto.self,
                RewardGoal.self
            )
        } catch {
            fatalError(
                "Unable to create SwiftData container: \(error)"
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
                .environmentObject(storeManager)
        }
        .modelContainer(modelContainer)
    }
}
