//
//  RemoteImage.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import SwiftUI

struct RemoteImage: View {
    
    let urlString: String
    
    var body: some View {
        AsyncImage(url: URL(string: urlString), scale: 1.0, transaction: .init(animation: .easeInOut)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if phase.error != nil {
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.white)
                        .padding(32)
                }
            } else {
                ZStack {
                    Color.gray.opacity(0.3)
                    ProgressView()
                        .scaleEffect(2.0)
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                }
                
            }
        }
        
    }
}


#Preview {
    let size = 123.0
    RemoteImage(urlString: "https://s.yimg.com/ny/api/res/1.2/Onq1adoghZAHhpsXXmF8Pw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyNDI7aD05MzE-/https://media.zenfs.com/en/insider_articles_922/c6ce8d0b9a7b28f9c2dee8171da98b8f")
        .frame(width: size*1.5, height: size)
        .clipped()
}
