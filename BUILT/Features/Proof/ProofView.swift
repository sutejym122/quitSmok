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
    private var photos:
        [MotivationPhoto]

    @State private var pickerItems:
        [PhotosPickerItem] = []

    @State private var isImporting =
        false

    @State private var errorMessage:
        String?

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    private var columns:
        [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [
                GridItem(
                    .flexible(),
                    spacing: 12
                )
            ]
        }

        return [
            GridItem(
                .flexible(),
                spacing: 12
            ),
            GridItem(
                .flexible(),
                spacing: 12
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(
                        alignment: .leading,
                        spacing:
                            BuiltTheme.Spacing
                                .xLarge
                    ) {
                        header

                        if let errorMessage {
                            BuiltStatusCard(
                                kind: .error,
                                title:
                                    "Photo could not be saved",
                                message:
                                    errorMessage,
                                primaryActionTitle:
                                    "Dismiss",
                                primaryAction: {
                                    self.errorMessage =
                                        nil
                                }
                            )
                        }

                        if photos.isEmpty {
                            emptyState
                        } else {
                            heroMessage
                            photoGrid
                        }
                    }
                    .padding(
                        .horizontal,
                        BuiltTheme.Spacing
                            .screenHorizontal
                    )
                    .padding(.top, 18)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)

                if isImporting {
                    importOverlay
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
            alignment: .center,
            spacing: BuiltTheme.Spacing.medium
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
                Image(
                    systemName:
                        isImporting
                        ? "hourglass"
                        : "plus"
                )
                .font(
                    .body
                    .weight(.bold)
                )
                .foregroundStyle(.black)
                .frame(
                    width:
                        BuiltTheme
                            .minimumTapTarget,
                    height:
                        BuiltTheme
                            .minimumTapTarget
                )
                .background(
                    BuiltTheme.accent,
                    in: Circle()
                )
            }
            .disabled(isImporting)
            .accessibilityLabel(
                isImporting
                ? "Importing photos"
                : "Add motivation photos"
            )
        }
    }

    private var emptyState: some View {
        VStack(
            spacing: BuiltTheme.Spacing.large
        ) {
            BuiltEmptyState(
                systemName:
                    "photo.badge.plus",
                title:
                    "Add your strongest photos",
                message:
                    "Choose gym photos, progress photos, or any image that reminds you what smoking would take away from."
            )

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
                    .accessibilityHidden(true)

                    Text("Choose photos")

                    Spacer()

                    Image(
                        systemName:
                            "arrow.right"
                    )
                    .accessibilityHidden(true)
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
            .disabled(isImporting)
        }
    }

    private var heroMessage: some View {
        BuiltHeroPanel(
            eyebrow:
                "Your body is evidence",
            title:
                "You worked too hard to let a five-minute urge negotiate with your future.",
            message:
                "\(photos.count) private motivation photo\(photos.count == 1 ? "" : "s") saved on this device.",
            systemName:
                "figure.strengthtraining.traditional"
        )
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
                .accessibilityLabel(
                    photo.isHero
                    ? "Today hero photo. \(photo.caption)"
                    : photo.caption
                )
                .accessibilityHint(
                    "Opens photo details"
                )
            }
        }
    }

    private var importOverlay: some View {
        ZStack {
            Color.black.opacity(0.24)
                .ignoresSafeArea()
                .accessibilityHidden(true)

            BuiltLoadingCard(
                title:
                    "Preparing your photos",
                message:
                    "Optimizing images privately on this device."
            )
            .padding(.horizontal, 28)
        }
        .allowsHitTesting(true)
    }

    @MainActor
    private func importPhotos(
        from items:
            [PhotosPickerItem]
    ) async {
        isImporting = true
        errorMessage = nil

        defer {
            isImporting = false
            pickerItems = []
        }

        var shouldAssignHero =
            photos.isEmpty

        var importedCount = 0

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

            modelContext.insert(
                MotivationPhoto(
                    imageData: optimized,
                    isHero:
                        shouldAssignHero
                )
            )

            shouldAssignHero = false
            importedCount += 1
        }

        guard importedCount > 0 else {
            errorMessage =
                "BUILT could not read the selected image. Try another photo."
            Haptics.warning()
            return
        }

        do {
            try modelContext.save()
            Haptics.success()
        } catch {
            errorMessage =
                "Your selected photos were prepared, but the local database could not save them. Please try again."
            Haptics.warning()
        }
    }
}

private struct PhotoThumbnail: View {
    let photo: MotivationPhoto

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    var body: some View {
        ZStack(
            alignment: .topTrailing
        ) {
            photoImage

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.black.opacity(0.72)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .accessibilityHidden(true)

            if photo.isHero {
                Label(
                    "HERO",
                    systemImage:
                        "star.fill"
                )
                .font(
                    .caption2
                    .weight(.bold)
                )
                .tracking(0.7)
                .foregroundStyle(.black)
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
                .accessibilityHidden(true)
            }

            VStack {
                Spacer()

                Text(photo.caption)
                    .font(
                        .subheadline
                        .weight(.semibold)
                    )
                    .foregroundStyle(.white)
                    .lineLimit(
                        dynamicTypeSize
                            .isAccessibilitySize
                        ? 4
                        : 2
                    )
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(15)
            }
        }
        .frame(
            minHeight:
                dynamicTypeSize
                    .isAccessibilitySize
                ? 320
                : 240
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius:
                    BuiltTheme.mediumRadius,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius:
                    BuiltTheme.mediumRadius,
                style: .continuous
            )
            .stroke(
                BuiltTheme.hairline,
                lineWidth: 1
            )
        }
    }

    @ViewBuilder
    private var photoImage: some View {
        if let image = UIImage(
            data: photo.imageData
        ) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(
                    maxWidth: .infinity
                )
                .frame(
                    minHeight:
                        dynamicTypeSize
                            .isAccessibilitySize
                        ? 320
                        : 240
                )
                .clipped()
        } else {
            BuiltTheme.elevated
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

    @State private var saveError:
        String?

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView {
                VStack(
                    spacing:
                        BuiltTheme.Spacing.large
                ) {
                    image
                    captionEditor
                    heroButton
                    deleteButton
                }
                .padding(
                    .horizontal,
                    BuiltTheme.Spacing
                        .screenHorizontal
                )
                .padding(.top, 10)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(
                .interactively
            )
            .scrollIndicators(.hidden)
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
                "This removes the photo only from BUILT. It does not delete the original from Photos."
            )
        }
        .alert(
            "Changes could not be saved",
            isPresented: Binding(
                get: {
                    saveError != nil
                },
                set: { presented in
                    if !presented {
                        saveError = nil
                    }
                }
            )
        ) {
            Button(
                "OK",
                role: .cancel
            ) {
                saveError = nil
            }
        } message: {
            Text(
                saveError
                ?? "Please try again."
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
                BuiltEmptyState(
                    systemName:
                        "photo",
                    title:
                        "Photo unavailable",
                    message:
                        "BUILT could not decode this saved image."
                )
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

    private var captionEditor:
        some View {
        VStack(
            alignment: .leading,
            spacing: BuiltTheme.Spacing.medium
        ) {
            Text("MESSAGE TO YOURSELF")
                .font(
                    .caption
                    .weight(.bold)
                )
                .tracking(1.3)
                .foregroundStyle(
                    BuiltTheme.accent
                )

            TextField(
                "Add a caption",
                text: $photo.caption,
                axis: .vertical
            )
            .lineLimit(2...6)
            .font(
                .title3
                .weight(.semibold)
            )
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
            .onSubmit {
                save()
            }

            Text(
                "This message appears with the image during moments when your identity matters most."
            )
            .font(.caption)
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
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
                    .accessibilityHidden(true)

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
                        systemName: "star"
                    )
                    .accessibilityHidden(true)

                    Text(
                        "Use on Today screen"
                    )

                    Spacer()

                    Image(
                        systemName:
                            "arrow.right"
                    )
                    .accessibilityHidden(true)
                }
            }
            .buttonStyle(
                BuiltPrimaryButtonStyle()
            )
        }
    }

    private var deleteButton: some View {
        Button(
            role: .destructive
        ) {
            showingDeleteAlert = true
        } label: {
            Label(
                "Delete photo",
                systemImage: "trash"
            )
        }
        .buttonStyle(
            BuiltDestructiveButtonStyle()
        )
    }

    private func makeHero() {
        for item in allPhotos {
            item.isHero =
                item === photo
        }

        save(successHaptic: true)
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

        do {
            try modelContext.save()
            dismiss()
        } catch {
            saveError =
                "The photo could not be removed from the local database."
            Haptics.warning()
        }
    }

    private func save(
        successHaptic: Bool = false
    ) {
        do {
            try modelContext.save()

            if successHaptic {
                Haptics.success()
            }
        } catch {
            saveError =
                "BUILT could not save this photo change."
            Haptics.warning()
        }
    }
}
