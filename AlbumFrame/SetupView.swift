//
//  SetupView.swift
//  PhotoFrame
//
//  Created by Nisala on 12/31/25.
//

import SwiftUI
import SwiftData

struct SetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var configs: [SlideshowConfig]
    @State private var config: SlideshowConfig?
    @State private var showSlideshow = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let config = config {
                    Group {
                        Text("Order").font(Font.headline)
                        OrderPickerView(order: Binding(
                            get: { config.order },
                            set: { config.order = $0 }
                        ))
                    }
                    Group {
                        Text("Delay between photos").font(Font.headline)
                        TimingPickerView(timing: Binding(
                            get: { config.timing },
                            set: { config.timing = $0 }
                        ))
                    }
                    Group {
                        Text("Album").font(Font.headline)
                        AlbumPickerView(albumIdentifier: Binding(
                            get: { config.albumIdentifier },
                            set: { config.albumIdentifier = $0 }
                        ))
                    }
                    
                    Button(action: {
                        showSlideshow = true
                    }) {
                        Text("Start Slideshow")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(config.albumIdentifier.isEmpty)
                } else {
                    ProgressView()
                }
            }
            .padding(.all)
            .onAppear {
                if configs.isEmpty {
                    let newConfig = SlideshowConfig(albumIdentifier: "", timing: 5, order: .sequential)
                    modelContext.insert(newConfig)
                    config = newConfig
                } else {
                    config = configs.first
                }
            }
        }
        .frame(maxWidth: 600)
        .fullScreenCover(isPresented: $showSlideshow) {
            if let config = config {
                SlideshowView(albumIdentifier: config.albumIdentifier, timing: config.timing, order: config.order)
            }
        }
    }
}

