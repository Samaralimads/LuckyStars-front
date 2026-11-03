//
//  WhiteCard.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI


struct WhiteCard<Content: View>: View {
    
    let title: String
    let description: String
    let content: Content
    
    init(
        title: String,
        description: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.content = content()
    }
    
    
    
    var body: some View {
        VStack(spacing: Spacing.xl) {

            VStack(spacing: Spacing.m) {

                Text(title)
                    .font(.luckyTitle)
                    .foregroundStyle(Color.luckyBlue)

                Text(description)
                    .font(.luckyBody)
                    .foregroundStyle(Color.charcoal)
                    .padding(.horizontal, Spacing.s)

            }
            .multilineTextAlignment(.center)

            VStack(spacing: Spacing.l) {
                content
            }

        }
        .padding(.top, 36)
        .padding(.bottom, 28)
        .padding(.horizontal, 20)
        .frame(maxWidth: 380)
        .luckyCard()
        .padding(.horizontal, 20)
    }
}


#Preview {
    WhiteCard(title: "This is the title that is longer now to test", description: "This is a short description, longer now to test the spacing"){
        Spacer()
        Text("And this is the content of the card")
    }.background { Image("LuckyBackground").resizable().scaledToFill().ignoresSafeArea() }
}
