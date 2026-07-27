import Foundation

public enum BuiltSharedConstants {
    public static let appGroupIdentifier = "group.com.sutej.built"
    public static let widgetSnapshotKey = "built.widget.snapshot.v1"
    public static let smokeFreeWidgetKind = "BuiltSmokeFreeWidget"

    public static let urlScheme = "built"
    public static let todayURL = URL(string: "built://today")!
    public static let rescueURL = URL(string: "built://rescue")!
    public static let proofURL = URL(string: "built://proof")!
    public static let fitnessURL = URL(string: "built://fitness")!
    public static let insightsURL = URL(string: "built://insights")!

    public static let notificationCategoryIdentifier = "BUILT_MOTIVATION"
    public static let notificationOpenRescueActionIdentifier = "BUILT_OPEN_RESCUE"
    public static let notificationRouteUserInfoKey = "built.route.url"
}

public extension Notification.Name {
    static let builtNotificationRouteDidChange = Notification.Name(
        "built.notification.route.did.change"
    )
}
