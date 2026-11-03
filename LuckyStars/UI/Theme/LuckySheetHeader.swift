//
//  LuckySheetHeader.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 29/10/2026.
//
//  Centered Gaegu title with the round close button on the right, for sheets.
//

import SwiftUI

struct LuckySheetHeader: View {
    let title: String
    var onClose: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.luckyScreenTitle)
                .foregroundStyle(Color.charcoal)

            HStack {
                Spacer()
                LuckyCloseButton(action: onClose)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 14)
    }
}

#Preview {
    LuckySheetHeader(title: "Filters") {}
        .background(Color.cardFill)
}
