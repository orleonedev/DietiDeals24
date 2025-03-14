//
//  NotificationCard.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/11/25.
//

import SwiftUI

struct NotificationCard: View {
    
    let notification: NotificationModel
    let onTap: ((UUID) -> Void)?
    
    var body: some View {
        HStack(alignment: .top, spacing: 12){
            
            RemoteImage(urlString: notification.imageUrl)
                .frame(width: 80, height: 80)
                .clipped()
                .clipShape(.rect(cornerRadius: 12))
                .aspectRatio(contentMode: .fit)
            
            
            VStack(alignment: .leading) {
                Text(notification.date.formatted())
                    .font(.caption)
                Text(notification.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(notification.auctionName)
                    .font(.title3)
                    .fontWeight(.medium)
                Text(notification.message.localized)
                    .font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(.quinary)
        .contentShape(Rectangle())
        .onTapGesture { onTap?(notification.auctionId) }
        .clipShape(.rect(cornerRadius: 12))
    }
}

#Preview {
    NotificationCard(notification: NotificationModel(id: UUID(), title: "Notification Title", message: "Notification Message", date: .now, auctionId: UUID(), auctionName: "Auction Name", imageUrl: "https://s.yimg.com/ny/api/res/1.2/Onq1adoghZAHhpsXXmF8Pw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyNDI7aD05MzE-/https://media.zenfs.com/en/insider_articles_922/c6ce8d0b9a7b28f9c2dee8171da98b8f"), onTap: { auctionID in })
        .padding()
        .frame(height: 192)
        .fixedSize(horizontal: false, vertical: false)
}
