import UIKit
import UserNotifications

final class AppDelegate:
    NSObject,
    UIApplicationDelegate,
    UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions
            launchOptions:
                [
                    UIApplication
                        .LaunchOptionsKey:
                        Any
                ]? = nil
    ) -> Bool {
        AppDiagnostics.recordLaunch()

        UNUserNotificationCenter
            .current()
            .delegate = self

        Task {
            await NotificationManager
                .shared
                .configureCategories()
        }

        return true
    }

    func userNotificationCenter(
        _ center:
            UNUserNotificationCenter,
        willPresent notification:
            UNNotification,
        withCompletionHandler
            completionHandler:
                @escaping (
                    UNNotificationPresentationOptions
                ) -> Void
    ) {
        completionHandler([
            .banner,
            .sound
        ])
    }

    func userNotificationCenter(
        _ center:
            UNUserNotificationCenter,
        didReceive response:
            UNNotificationResponse,
        withCompletionHandler
            completionHandler:
                @escaping () -> Void
    ) {
        let userInfo =
            response
                .notification
                .request
                .content
                .userInfo

        let fallbackRoute =
            response.actionIdentifier
            == BuiltSharedConstants
                .notificationOpenRescueActionIdentifier
            ? BuiltSharedConstants
                .rescueURL
                .absoluteString
            : BuiltSharedConstants
                .todayURL
                .absoluteString

        let route = userInfo[
            BuiltSharedConstants
                .notificationRouteUserInfoKey
        ] as? String
        ?? fallbackRoute

        NotificationRouteStore.save(
            urlString: route
        )

        NotificationCenter.default.post(
            name:
                .builtNotificationRouteDidChange,
            object: nil
        )

        completionHandler()
    }
}
