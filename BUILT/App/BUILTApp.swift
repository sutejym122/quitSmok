import SwiftUI
import SwiftData

@main
struct BUILTApp: App {
    @UIApplicationDelegateAdaptor(
        AppDelegate.self
    )
    private var appDelegate

    @StateObject
    private var storeManager =
        StoreManager()

    private let modelContainer:
        ModelContainer

    init() {
        do {
            modelContainer =
                try AppModelContainerFactory
                    .make()

            AppDiagnostics
                .recordModelContainerReady(
                    inMemory: false
                )
        } catch {
            AppDiagnostics
                .recordModelContainerFailure(
                    error
                )

            fatalError(
                "Unable to create SwiftData container: \(error)"
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(
                    .dark
                )
                .environmentObject(
                    storeManager
                )
        }
        .modelContainer(modelContainer)
    }
}
