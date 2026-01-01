//
//  OrderPickerView.swift
//  PhotoFrame
//
//  Created by Nisala on 12/31/25.
//

import SwiftUI

struct OrderPickerView: View {
    @Binding var order: PhotoOrder
    
    var body: some View {
        Picker("Order", selection: $order) {
            ForEach(PhotoOrder.allCases, id: \.self) { orderOption in
                Text(orderOption.rawValue).tag(orderOption)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    OrderPickerView(order: .constant(.sequential))
        .padding()
}
