//
//  SlideshowView.swift
//  PhotoFrame
//
//  Created by Nisala on 12/31/25.
//

import SwiftUI
import Photos

let SCALED_IN = 1.1
let SCALED_OUT = 1.0

struct SlideshowView: View {
    let albumIdentifier: String
    let timing: Int
    let order: PhotoOrder
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentImage: UIImage?
    @State private var assets: [PHAsset] = []
    @State private var shuffledIndices: [Int] = []
    @State private var currentIndex: Int = 0
    @State private var timer: Timer?
    @State private var showControls = true
    @State private var hideControlsTask: Task<Void, Never>?
    @State private var imageScale: CGFloat = 1.0
    @State private var zoomDirection: ZoomDirection = .zoomIn
    
    enum ZoomDirection {
        case zoomIn
        case zoomOut
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let currentImage = currentImage {
                Image(uiImage: currentImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(imageScale)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .tint(.white)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding()
                    }
                }
                Spacer()
            }
            .opacity(showControls ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: showControls)
        }
        .onTapGesture {
            showControlsTemporarily()
        }
        .onAppear {
            fetchPhotos()
            scheduleControlsHiding()
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            timer?.invalidate()
            hideControlsTask?.cancel()
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    private func fetchPhotos() {
        DispatchQueue.main.async {
            guard let album = PHAssetCollection.fetchAssetCollections(
                withLocalIdentifiers: [albumIdentifier],
                options: nil
            ).firstObject else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
            
            let fetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)
            assets = fetchResult.objects(at: IndexSet(0..<fetchResult.count))
            
            guard !assets.isEmpty else { return }
            
            if order == .random {
                shuffledIndices = Array(0..<assets.count).shuffled()
            } else {
                shuffledIndices = Array(0..<assets.count)
            }
            currentIndex = 0
            
            loadCurrentImage()
            startTimer()
        }
    }
    
    private func loadCurrentImage() {
        guard !shuffledIndices.isEmpty else { return }
        
        let assetIndex = shuffledIndices[currentIndex]
        let asset = assets[assetIndex]
        
        let imageManager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(
            for: asset,
            targetSize: PHImageManagerMaximumSize,
            contentMode: .aspectFit,
            options: options
        ) { image, _ in
            DispatchQueue.main.async {
                self.currentImage = image
                self.startZoomAnimation()
            }
        }
    }
    
    private func startZoomAnimation() {
        zoomDirection = Bool.random() ? .zoomIn : .zoomOut
        
        imageScale = zoomDirection == .zoomIn ? SCALED_OUT : SCALED_IN
        
        withAnimation(.linear(duration: TimeInterval(timing))) {
            imageScale = zoomDirection == .zoomIn ? SCALED_IN : SCALED_OUT
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(timing), repeats: true) { _ in
            advanceToNextImage()
        }
    }
    
    private func advanceToNextImage() {
        guard !shuffledIndices.isEmpty else { return }
        
        currentIndex = (currentIndex + 1) % shuffledIndices.count
        
        // Re-shuffle when we complete a cycle in random mode
        if currentIndex == 0 && order == .random {
            shuffledIndices.shuffle()
        }
        
        loadCurrentImage()
    }
    
    private func showControlsTemporarily() {
        showControls = true
        scheduleControlsHiding()
    }
    
    private func scheduleControlsHiding() {
        hideControlsTask?.cancel()
        hideControlsTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                showControls = false
            }
        }
    }
}
