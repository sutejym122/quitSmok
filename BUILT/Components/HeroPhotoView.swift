import SwiftUI
import UIKit

struct HeroPhotoView: View {
    let photo: MotivationPhoto?

    var body: some View {
        ZStack {
            if let photo,
               let uiImage = UIImage(
                   data: photo.imageData
               ) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [
                        BuiltTheme.elevated,
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 18) {
                    Image(
                        systemName:
                            "figure.strengthtraining.traditional"
                    )
                    .font(
                        .system(
                            size: 72,
                            weight: .thin
                        )
                    )
                    .foregroundStyle(
                        Color.white.opacity(0.72)
                    )

                    Text(
                        """
                        ADD THE PHOTO THAT
                        REMINDS YOU WHO YOU ARE
                        """
                    )
                    .font(
                        .system(
                            size: 12,
                            weight: .semibold
                        )
                    )
                    .tracking(1.6)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        BuiltTheme.textSecondary
                    )
                }
            }

            LinearGradient(
                colors: [
                    Color.black.opacity(0.05),
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.86)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(height: 500)
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: BuiltTheme.largeRadius,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: BuiltTheme.largeRadius,
                style: .continuous
            )
            .stroke(
                BuiltTheme.hairline,
                lineWidth: 1
            )
        }
        .clipped()
    }
}
