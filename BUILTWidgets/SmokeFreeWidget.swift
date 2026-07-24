import WidgetKit
import SwiftUI

struct SmokeFreeEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot
}

struct SmokeFreeWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SmokeFreeEntry {
        SmokeFreeEntry(
            date: .now,
            snapshot: .placeholder
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SmokeFreeEntry) -> Void
    ) {
        completion(
            SmokeFreeEntry(
                date: .now,
                snapshot: WidgetSnapshotStore.load()
            )
        )
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<SmokeFreeEntry>) -> Void
    ) {
        let now = Date.now
        let snapshot = WidgetSnapshotStore.load()
        let entry = SmokeFreeEntry(
            date: now,
            snapshot: snapshot
        )

        let nextRefresh = Calendar.current.date(
            byAdding: .minute,
            value: 15,
            to: now
        ) ?? now.addingTimeInterval(15 * 60)

        completion(
            Timeline(
                entries: [entry],
                policy: .after(nextRefresh)
            )
        )
    }
}

struct SmokeFreeWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: BuiltSharedConstants.smokeFreeWidgetKind,
            provider: SmokeFreeWidgetProvider()
        ) { entry in
            SmokeFreeWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    BuiltWidgetBackground()
                }
                .widgetURL(BuiltSharedConstants.todayURL)
        }
        .configurationDisplayName("BUILT Smoke-Free")
        .description(
            "Keep your smoke-free time, protected money, and identity visible."
        )
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

struct BuiltWidgetBackground: View {
    var body: some View {
        ZStack {
            Color(
                red: 0.025,
                green: 0.027,
                blue: 0.035
            )

            Circle()
                .fill(
                    Color(
                        red: 0.64,
                        green: 1.00,
                        blue: 0.62
                    )
                    .opacity(0.16)
                )
                .frame(width: 220, height: 220)
                .blur(radius: 45)
                .offset(x: 90, y: -90)

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
