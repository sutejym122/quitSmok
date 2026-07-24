import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct ProofView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \MotivationPhoto.createdAt,
        order: .reverse
    )
    private var photos: [MotivationPhoto]

    @State private var pickerItems:
        [PhotosPickerItem] = []

    @State private var isImporting =
        false

    private let columns = [
        GridItem(
            .flexible(),
            spacing: 12
        ),
        GridItem(
            .flexible(),
            spacing: 12
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing: 24
                    ) {
                        header

                        if photos.isEmpty {
                            emptyState
                        } else {
                            heroMessage
                            photoGrid
                        }
                    }
                    .padding(
                        .horizontal,
                        20
                    )
                    .padding(.top, 18)
                    .padding(
                        .bottom,
                        36
                    )
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .onChange(
            of: pickerItems
        ) { _, newItems in
            guard !newItems.isEmpty else {
                return
            }

            Task {
                await importPhotos(
                    from: newItems
                )
            }
        }
    }

    private var header: some View {
        HStack(
            alignment: .bottom
        ) {
            SectionHeader(
                eyebrow:
                    "Physique vault",
                title:
                    "Proof of who you are."
            )

            Spacer()

            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: 8,
                matching: .images
            ) {
                ZStack {
                    Circle()
                        .fill(
                            BuiltTheme.accent
                        )
                        .frame(
                            width: 46,
                            height: 46
                        )

                    if isImporting {
                        ProgressView()
                            .tint(.black)
                    } else {
                        Image(
                            systemName: "plus"
                        )
                        .font(
                            .system(
                                size: 17,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            .black
                        )
                    }
                }
            }
            .disabled(isImporting)
            .accessibilityLabel(
                "Add motivation photos"
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 22) {
            ZStack {
                RoundedRectangle(
                    cornerRadius:
                        BuiltTheme.largeRadius,
                    style: .continuous
                )
                .fill(
                    LinearGradient(
                        colors: [
                            BuiltTheme.elevated,
                            Color.black
                        ],
                        startPoint:
                            .topLeading,
                        endPoint:
                            .bottomTrailing
                    )
                )
                .frame(height: 420)

                VStack(spacing: 20) {
                    Image(
                        systemName:
                            "photo.badge.plus"
                    )
                    .font(
                        .system(
                            size: 62,
                            weight: .thin
                        )
                    )
                    .foregroundStyle(
                        BuiltTheme.accent
                    )

                    VStack(spacing: 8) {
                        Text(
                            "Add your strongest photos"
                        )
                        .font(
                            .system(
                                size: 24,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            BuiltTheme.textPrimary
                        )

                        Text(
                            """
                            Choose gym photos, progress photos, or any image that reminds you what smoking would take away from.
                            """
                        )
                        .font(.system(size: 15))
                        .foregroundStyle(
                            BuiltTheme.textSecondary
                        )
                        .multilineTextAlignment(
                            .center
                        )
                        .padding(
                            .horizontal,
                            24
                        )
                    }
                }
            }

            PhotosPicker(
                selection: $pickerItems,
                maxSelectionCount: 8,
                matching: .images
            ) {
                HStack {
                    Image(
                        systemName:
                            "photo.on.rectangle.angled"
                    )

                    Text("Choose photos")

                    Spacer()

                    Image(
                        systemName:
                            "arrow.right"
                    )
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
            .disabled(isImporting)
        }
    }

    private var heroMessage: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text(
                "YOUR BODY IS EVIDENCE"
            )
            .font(
                .system(
                    size: 11,
                    weight: .bold
                )
            )
            .tracking(1.8)
            .foregroundStyle(
                BuiltTheme.accent
            )

            Text(
                """
                You worked too hard to let a five-minute urge negotiate with your future.
                """
            )
            .font(
                .system(
                    size: 25,
                    weight: .semibold
                )
            )
            .tracking(-0.5)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .fixedSize(
                horizontal: false,
                vertical: true
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 22)
    }

    private var photoGrid: some View {
        LazyVGrid(
            columns: columns,
            spacing: 12
        ) {
            ForEach(photos) { photo in
                NavigationLink {
                    PhotoDetailView(
                        photo: photo
                    )
                } label: {
                    PhotoThumbnail(
                        photo: photo
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    @MainActor
    private func importPhotos(
        from items:
            [PhotosPickerItem]
    ) async {
        isImporting = true

        defer {
            isImporting = false
            pickerItems = []
        }

        var shouldAssignHero =
            photos.isEmpty

        for item in items {
            guard
                let data =
                    try? await item
                        .loadTransferable(
                            type: Data.self
                        ),
                let optimized =
                    ImageProcessor
                        .optimizedJPEGData(
                            from: data
                        )
            else {
                continue
            }

            let photo =
                MotivationPhoto(
                    imageData:
                        optimized,
                    isHero:
                        shouldAssignHero
                )

            modelContext.insert(
                photo
            )

            shouldAssignHero =
                false
        }

        try? modelContext.save()
        Haptics.success()
    }
}

private struct PhotoThumbnail: View {
    let photo: MotivationPhoto

    var body: some View {
        ZStack(
            alignment: .topTrailing
        ) {
            if let image = UIImage(
                data: photo.imageData
            ) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        maxWidth: .infinity
                    )
                    .frame(height: 240)
                    .clipped()
            } else {
                BuiltTheme.elevated
                    .frame(height: 240)
            }

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.65)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            if photo.isHero {
                Label(
                    "HERO",
                    systemImage:
                        "star.fill"
                )
                .font(
                    .system(
                        size: 9,
                        weight: .bold
                    )
                )
                .tracking(1)
                .foregroundStyle(
                    .black
                )
                .padding(
                    .horizontal,
                    10
                )
                .padding(
                    .vertical,
                    7
                )
                .background(
                    BuiltTheme.accent,
                    in: Capsule()
                )
                .padding(10)
            }

            VStack {
                Spacer()

                Text(photo.caption)
                    .font(
                        .system(
                            size: 13,
                            weight: .semibold
                        )
                    )
                    .foregroundStyle(
                        .white
                    )
                    .lineLimit(2)
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(14)
            }
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 22,
                style: .continuous
            )
            .stroke(
                BuiltTheme.hairline,
                lineWidth: 1
            )
        }
    }
}

struct PhotoDetailView: View {
    @Bindable var photo:
        MotivationPhoto

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \MotivationPhoto.createdAt,
        order: .reverse
    )
    private var allPhotos:
        [MotivationPhoto]

    @State private var showingDeleteAlert =
        false

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView {
                VStack(spacing: 22) {
                    image
                    captionEditor
                    heroButton
                    deleteButton
                }
                .padding(
                    .horizontal,
                    20
                )
                .padding(.top, 10)
                .padding(
                    .bottom,
                    36
                )
            }
        }
        .navigationTitle("Photo")
        .navigationBarTitleDisplayMode(
            .inline
        )
        .toolbarBackground(
            .ultraThinMaterial,
            for: .navigationBar
        )
        .toolbarBackground(
            .visible,
            for: .navigationBar
        )
        .alert(
            "Delete this photo?",
            isPresented:
                $showingDeleteAlert
        ) {
            Button(
                "Delete",
                role: .destructive
            ) {
                deletePhoto()
            }

            Button(
                "Cancel",
                role: .cancel
            ) {}
        } message: {
            Text(
                """
                This removes the photo only from BUILT. It does not delete the original from Photos.
                """
            )
        }
    }

    private var image: some View {
        Group {
            if let uiImage = UIImage(
                data: photo.imageData
            ) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                BuiltTheme.elevated
                    .frame(height: 360)
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius:
                    BuiltTheme.largeRadius,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius:
                    BuiltTheme.largeRadius,
                style: .continuous
            )
            .stroke(
                BuiltTheme.hairline,
                lineWidth: 1
            )
        }
    }

    private var captionEditor: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text(
                "MESSAGE TO YOURSELF"
            )
            .font(
                .system(
                    size: 11,
                    weight: .bold
                )
            )
            .tracking(1.6)
            .foregroundStyle(
                BuiltTheme.accent
            )

            TextField(
                "Add a caption",
                text: $photo.caption,
                axis: .vertical
            )
            .lineLimit(2...5)
            .font(
                .system(
                    size: 21,
                    weight: .semibold
                )
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .onChange(
                of: photo.caption
            ) { _, _ in
                try? modelContext.save()
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard()
    }

    @ViewBuilder
    private var heroButton: some View {
        if photo.isHero {
            Button {} label: {
                HStack {
                    Image(
                        systemName:
                            "star.fill"
                    )

                    Text(
                        "Current Today photo"
                    )

                    Spacer()
                }
            }
            .buttonStyle(
                BuiltSecondaryButtonStyle()
            )
            .disabled(true)
        } else {
            Button {
                makeHero()
            } label: {
                HStack {
                    Image(
                        systemName:
                            "star"
                    )

                    Text(
                        "Use on Today screen"
                    )

                    Spacer()

                    Image(
                        systemName:
                            "arrow.right"
                    )
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            showingDeleteAlert = true
        } label: {
            Text("Delete photo")
                .font(
                    .system(
                        size: 15,
                        weight: .semibold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.danger
                )
                .frame(
                    maxWidth: .infinity
                )
                .padding(.vertical, 15)
        }
    }

    private func makeHero() {
        for item in allPhotos {
            item.isHero =
                item === photo
        }

        try? modelContext.save()
        Haptics.success()
    }

    private func deletePhoto() {
        let wasHero =
            photo.isHero

        modelContext.delete(photo)

        if wasHero,
           let replacement =
            allPhotos.first(
                where: {
                    $0 !== photo
                }
            ) {
            replacement.isHero = true
        }

        try? modelContext.save()
        dismiss()
    }
}
