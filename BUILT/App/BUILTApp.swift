import SwiftUI
import SwiftData
import UIKit

@main
struct BUILTApp: App {
    @UIApplicationDelegateAdaptor(
        AppDelegate.self
    )
    private var appDelegate

    @StateObject
    private var storeManager:
        StoreManager

    private let modelContainer:
        ModelContainer

    private let uiTestRuntime:
        UITestRuntime

    init() {
        let runtime =
            UITestRuntime.current

        uiTestRuntime = runtime

        let defaults =
            UserDefaults.standard

        if let entitlement =
            runtime
                .proEntitlementOverride {
            EntitlementCache(
                defaults: defaults
            )
            .save(entitlement)
        }

        _storeManager =
            StateObject(
                wrappedValue:
                    StoreManager(
                        defaults:
                            defaults,
                        automaticallyPrepares:
                            !runtime
                                .isRunning,
                        observesTransactionUpdates:
                            !runtime
                                .isRunning
                    )
            )

        do {
            let container =
                try AppModelContainerFactory
                    .make(
                        inMemory:
                            runtime
                                .usesInMemoryStore
                    )

            try runtime.seed(
                modelContainer:
                    container
            )

            modelContainer =
                container

            AppDiagnostics
                .recordModelContainerReady(
                    inMemory:
                        runtime
                            .usesInMemoryStore
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

        if runtime.isRunning {
            UIView.setAnimationsEnabled(
                false
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
                .transaction {
                    transaction in

                    guard
                        uiTestRuntime
                            .isRunning
                    else {
                        return
                    }

                    transaction.animation =
                        nil
                    transaction
                        .disablesAnimations =
                        true
                }
        }
        .modelContainer(modelContainer)
    }
}
