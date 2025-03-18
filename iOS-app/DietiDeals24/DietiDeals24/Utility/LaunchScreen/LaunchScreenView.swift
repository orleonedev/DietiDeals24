//
//  LaunchScreenView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/6/25.
//

import SwiftUI

struct LaunchScreenView: View {
    
    let appversion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    let bundleversion: String = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    @State private var opacity: CGFloat = 0
    @FocusState var focused: Bool
    var body: some View {
        ZStack {
            Color.uninaBlu
                .edgesIgnoringSafeArea(.all)
            TextField("", text: .constant(""))
                .opacity(0)
                .focused($focused)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        focused = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focused = false
                        }
                    }
                }
            
            VStack(spacing: 32){
                Image("AppIconImage")
                    .resizable()
                    .frame(width: 256, height: 256)
                    .clipShape(.rect(cornerRadius: 256/6.4))
                
                Text("DietiDeals24")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.dietiYellow)
                    .padding()
                
                VStack(spacing: 8) {
                    Text(appversion + "(\(bundleversion))" )
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.dietiYellow)
                    Text("INGSW2324_63")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.dietiYellow)
                    HStack(alignment: .top) {
                        VStack{
                            Text("Oreste Leone\nN86001980")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.dietiYellow)
                        }
                        VStack{
                            Text("Giuseppe Falso\nN86002941")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.dietiYellow)
                        }
                    }
                }
            }
            .ignoresSafeArea()
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
