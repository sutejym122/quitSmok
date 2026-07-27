import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct ProofAccessView: View {
    @EnvironmentObject
    private var storeManager: StoreManager

    var body: some View {
        if storeManager.hasPro {
            ProofView()
        } else {
            FreeProofView()
        }
    }
}

private struct FreeProofView: View {
    @Environment(\.modelContext)
    private var modelContext

    @EnvironmentObject
    private var storeManager: StoreManager

    @Query(
        sort: \MotivationPhoto.createdAt,
        order: .reverse
    )
    private var photos: [MotivationPhoto]

    @State private var pickerItem: PhotosPickerItem?
    @State private var isImporting = false
    @State private var showingPaywall = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var canAddPhoto: Bool {
        ProAccessPolicy.canAddMotivationPhoto(
            hasPro: storeManager.hasPro,
            photoCount: photos.count
        )
    }

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
                            identityCard
                            photoGrid
                            upgradeCard
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 38)
                }

                if isImporting {
                    ProgressView("Preparing photo…")
                        .padding(18)
                        .builtCard()
                }
            }
            .toolbar(
                .hidden,
                for: .navigationBar
            )
        }
        .onChange(of: pickerItem) { _, newItem in
            guard let newItem else {
                return
            }

            Task {
                await importPhoto(from: newItem)
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(
                context: .motivationPhotos
            )
            .environmentObject(storeManager)
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            SectionHeader(
                eyebrow: "Physique vault",
                title: "Proof of who you are."
            )

            Spacer()

            if canAddPhoto {
                PhotosPicker(
                    selection: $pickerItem,
                    matching: .images
                ) {
                    addButtonLabel
                }
                .disabled(isImporting)
            } else {
                Button {
                    showingPaywall = true
                } label: {
                    addButtonLabel
                        .overlay(alignment: .bottomTrailing) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 18, height: 18)
                                .background(.white, in: Circle())
                                .offset(x: 2, y: 2)
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var addButtonLabel: some View {
        Image(systemName: "plus")
            .font(
                .system(
                    size: 17,
                    weight: .bold
                )
            )
            .foregroundStyle(.black)
            .frame(width: 46, height: 46)
            .background(
                BuiltTheme.accent,
                in: Circle()
            )
            .accessibilityLabel(
                canAddPhoto
                    ? "Add motivation photo"
                    : "Unlock unlimited motivation photos"
            )
    }

    private var emptyState: some View {
        VStack(spacing: 22) {
            Image(systemName: "photo.badge.plus")
                .font(
                    .system(
                        size: 58,
                        weight: .thin
                    )
                )
                .foregroundStyle(
                    BuiltTheme.accent
                )

            Text("Choose your strongest photo")
                .font(
                    .system(
                        size: 26,
                        weight: .bold
                    )
                )
                .foregroundStyle(
                    BuiltTheme.textPrimary
                )

            Text(
                "Your first motivation photo is free. It becomes visible on Today whenever you need to remember what you are protecting."
            )
            .font(.system(size: 15))
            .foregroundStyle(
                BuiltTheme.textSecondary
            )
            .multilineTextAlignment(.center)
            .fixedSize(
                horizontal: false,
                vertical: true
            )

            PhotosPicker(
                selection: $pickerItem,
                matching: .images
            ) {
                HStack {
                    Image(
                        systemName:
                            "photo.on.rectangle.angled"
                    )
                    Text("Choose my photo")
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
        .frame(
            maxWidth: .infinity
        )
        .builtCard(padding: 26)
    }

    private var identityCard: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            Text("YOUR BODY IS EVIDENCE")
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
                "Your free vault keeps one image visible. Pro turns it into a complete private identity library."
            )
            .font(
                .system(
                    size: 22,
                    weight: .semibold
                )
            )
            .tracking(-0.4)
            .foregroundStyle(
                BuiltTheme.textPrimary
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .builtCard(padding: 20)
    }

    private var photoGrid: some View {
        LazyVGrid(
            columns: columns,
            spacing: 12
        ) {
            ForEach(photos) { photo in
                NavigationLink {
                    FreePhotoEditor(photo: photo)
                } label: {
                    FreePhotoTile(photo: photo)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var upgradeCard: some View {
        UpgradeCard(
            title: "Build the complete physique vault",
            message:
                "Add unlimited gym photos, progress pictures, confidence reminders, and the moments that make smoking feel incompatible with your identity.",
            action: {
                showingPaywall = true
            }
        )
    }

    @MainActor
    private func importPhoto(
        from item: PhotosPickerItem
    ) async {
        guard canAddPhoto else {
            showingPaywall = true
            pickerItem = nil
            return
        }

        isImporting = true
        defer {
            isImporting = false
            pickerItem = nil
        }

        guard
            let data = try? await item.loadTransferable(
                type: Data.self
            ),
            let optimized =
                ImageProcessor.optimizedJPEGData(
                    from: data
                )
        else {
            Haptics.warning()
            return
        }

        let photo = MotivationPhoto(
            imageData: optimized,
            caption: "I protect what I built.",
            isHero: photos.isEmpty
        )

        modelContext.insert(photo)

        do {
            try modelContext.save()
            Haptics.success()
        } catch {
            modelContext.delete(photo)
            Haptics.warning()
        }
    }
}

private struct FreePhotoTile: View {
    let photo: MotivationPhoto

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = UIImage(
                data: photo.imageData
            ) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .frame(
                        maxWidth: .infinity
                    )
                    .clipped()
            } else {
                BuiltTheme.elevated
                    .frame(height: 240)
            }

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.72)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            if photo.isHero {
                Label(
                    "HERO",
                    systemImage: "star.fill"
                )
                .font(
                    .system(
                        size: 9,
                        weight: .bold
                    )
                )
                .foregroundStyle(.black)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
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
                    .foregroundStyle(.white)
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

private struct FreePhotoEditor: View {
    @Bindable var photo: MotivationPhoto

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.modelContext)
    private var modelContext

    @Query(
        sort: \MotivationPhoto.createdAt,
        order: .reverse
    )
    private var allPhotos: [MotivationPhoto]

    @State private var showingDeleteAlert = false

    var body: some View {
        ZStack {
            AmbientBackground()

            ScrollView {
                VStack(spacing: 20) {
                    photoView
                    captionCard
                    heroButton
                    deleteButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 36)
            }
        }
        .navigationTitle("Proof")
        .navigationBarTitleDisplayMode(.inline)
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
            isPresented: $showingDeleteAlert
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
                "This removes only BUILT's private copy. The original remains in Photos."
            )
        }
    }

    private var photoView: some View {
        Group {
            if let image = UIImage(
                data: photo.imageData
            ) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                BuiltTheme.elevated
                    .frame(height: 360)
            }
        }
        .frame(
            maxWidth: .infinity
        )
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

    private var captionCard: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            Text("MESSAGE TO YOURSELF")
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
                "Motivation caption",
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
                        systemName: "star.fill"
                    )
                    Text("Current Today photo")
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
                    Image(systemName: "star")
                    Text("Use on Today screen")
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
            item.isHero = item === photo
        }

        try? modelContext.save()
        Haptics.success()
    }

    private func deletePhoto() {
        let wasHero = photo.isHero
        let replacement = allPhotos.first {
            $0 !== photo
        }

        modelContext.delete(photo)

        if wasHero {
            replacement?.isHero = true
        }

        try? modelContext.save()
        dismiss()
    }
}
