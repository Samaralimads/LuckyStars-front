//
//  Background.swift
//  LuckyStars
//
//  Created by Samara Lima da Silva on 10/02/2026.
//

import SwiftUI

struct Background<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                // In .background so the artwork never affects the layout size of the screen.
                ZStack {
                    Image("LuckyBackground")
                        .resizable()
                        .scaledToFill()
                        .accessibilityHidden(true)
                }
                .clipped()
                .ignoresSafeArea()
            }
    }
}


#Preview {
    Background(){
        
        Text("This is the current background")
        
    }
}
