//
//  TimingPickerView.swift
//  PhotoFrame
//
//  Created by Nisala on 12/31/25.
//

import SwiftUI

struct TimingPickerView: View {
    @Binding var timing: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Slider(value: Binding(get: {
                Double(timing)
            }, set: {
                timing = Int($0)
            }), in: 1...20, step: 1)
            Text("\(timing) second\(timing > 1 ? "s" : "")").font(Font.caption)
        }
    }
}

