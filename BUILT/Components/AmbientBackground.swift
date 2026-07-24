import SwiftUI

struct AmbientBackground: View {
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                BuiltTheme.background

                Circle()
                    .fill(
                        BuiltTheme.accent.opacity(0.12)
                    )
                    .frame(
                        width: proxy.size.width * 0.95
                    )
                    .blur(radius: 95)
                    .offset(
                        x: proxy.size.width * 0.35,
                        y: -proxy.size.height * 0.28
                    )

                Circle()
                    .fill(
                        BuiltTheme.accentSoft.opacity(0.10)
                    )
                    .frame(
                        width: proxy.size.width * 0.90
                    )
                    .blur(radius: 110)
                    .offset(
                        x: -proxy.size.width * 0.42,
                        y: proxy.size.height * 0.30
                    )

                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.28)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
    }
}
