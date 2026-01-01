//
//  AlbumPickerView.swift
//  PhotoFrame
//
//  Created by Nisala on 12/31/25.
//

import Photos
import SwiftUI

struct AlbumPickerView: View {
    @Binding var albumIdentifier: String
    @State private var albums: [PHAssetCollection] = []
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(albums.indices, id: \.self) { idx in
                let album = albums[idx]
                let isFirst = idx == 0
                let isLast = idx == albums.count - 1
                let isSingle = albums.count == 1
                let cornerRadius: CGFloat = 10
                let corners: UIRectCorner = isSingle ? .allCorners : isFirst ? [.topLeft, .topRight] : isLast ? [.bottomLeft, .bottomRight] : []

                Button(action: {
                    albumIdentifier = album.localIdentifier
                }) {
                    HStack {
                        Text(album.localizedTitle ?? "Untitled Album")
                        Spacer()
                        if album.localIdentifier == albumIdentifier {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .padding()
                    .background(
                        RoundedCorner(radius: cornerRadius, corners: corners)
                            .fill(.secondary.opacity(0.1))
                    )
                }
                .buttonStyle(.plain)
                if !isLast {
                    Divider()
                }
            }
        }
        .onAppear {
            fetchAlbums()
        }
    }
    
    func fetchAlbums() {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            let fetchOptions = PHFetchOptions()
            let userAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            albums = userAlbums.objects(at: IndexSet(0..<userAlbums.count))
                .sorted(by: { $0.localizedTitle ?? "" < $1.localizedTitle ?? "" })
        }
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = 10.0
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
