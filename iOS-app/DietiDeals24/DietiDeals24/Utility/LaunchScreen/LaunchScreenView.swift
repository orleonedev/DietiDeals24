//
//  LaunchScreenView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/6/25.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var opacity: CGFloat = 0
    var body: some View {
        ZStack {
            Color.uninaBlu
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 32){
                Image("AppIconImage")
                    .resizable()
                    .frame(width: 256, height: 256)
                    .clipShape(.rect(cornerRadius: 256/6.4))
                
                Text("Dieti Deals 24")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.dietiYellow)
                    .padding()
            }
            .opacity(opacity)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.opacity = 1
                }
            }
            .animation(.easeInOut, value: opacity)
        }
    }
}

#Preview {
    LaunchScreenView()
}
