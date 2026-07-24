import Foundation
import UIKit

enum ImageProcessor {
    static func optimizedJPEGData(
        from originalData: Data,
        maximumDimension: CGFloat = 1_800,
        compressionQuality: CGFloat = 0.84
    ) -> Data? {
        guard let image = UIImage(
            data: originalData
        ) else {
            return nil
        }

        let originalSize = image.size

        let longestSide = max(
            originalSize.width,
            originalSize.height
        )

        let scale = min(
            1,
            maximumDimension
                / max(longestSide, 1)
        )

        let targetSize = CGSize(
            width: max(
                1,
                originalSize.width * scale
            ),
            height: max(
                1,
                originalSize.height * scale
            )
        )

        let format =
            UIGraphicsImageRendererFormat.default()

        format.scale = 1
        format.opaque = true

        let renderer =
            UIGraphicsImageRenderer(
                size: targetSize,
                format: format
            )

        let renderedImage =
            renderer.image { context in
                UIColor.black.setFill()

                context.cgContext.fill(
                    CGRect(
                        origin: .zero,
                        size: targetSize
                    )
                )

                image.draw(
                    in: CGRect(
                        origin: .zero,
                        size: targetSize
                    )
                )
            }

        return renderedImage.jpegData(
            compressionQuality:
                compressionQuality
        )
    }
}
