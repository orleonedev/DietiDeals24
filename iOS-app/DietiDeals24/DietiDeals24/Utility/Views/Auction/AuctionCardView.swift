//
//  AuctionCardView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 2/24/25.
//
import SwiftUI

struct AuctionCardView: View {
    
    var auction: AuctionCardModel
    @State private var countdown: String = "00:00:00"
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8){
            GeometryReader { proxy in
                RemoteImage(urlString: auction.coverUrl)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .clipShape(.rect(cornerRadius: 12))
            }
            .aspectRatio(1.77, contentMode: .fit)
            VStack(alignment: .leading, spacing: 4){
                Text(auction.name)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .multilineTextAlignment(.leading)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(auction.auctionType.label)
                    .font(.callout)
                    .foregroundColor(.secondary)
                
                Text("\(auction.price) €")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if auction.auctionType == .incremental {
                    Text("\(auction.bidsCount) bid\(auction.bidsCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(countdown)
                    .monospacedDigit()
                    .font(.subheadline)
                    .foregroundStyle(.accent)
                    .contentTransition(.numericText(countsDown: true))
                    .lineLimit(2, reservesSpace: true)
                
                    Spacer()
                
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            self.scheduleTimer()
            self.updateCountdown()
        }
        .onDisappear {
            self.timer?.invalidate()
        }
        .animation(.easeInOut, value: countdown)
    }
}

extension AuctionCardView {
    
    /// Schedules a timer with an interval based on how much time is remaining.
        private func scheduleTimer() {
            let interval = desiredInterval()
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                self.updateCountdown()
                self.adjustTimerIfNeeded()
            }
        }
        
        /// Adjusts the timer if needed when the remaining time crosses the threshold.
    private func adjustTimerIfNeeded() {
            let currentInterval = timer?.timeInterval ?? 1
            let newInterval = desiredInterval()
            if currentInterval != newInterval {
                scheduleTimer()
            }
        }
        
        /// Determines the appropriate timer interval.
        /// - Returns: 60 seconds if more than one hour remains, otherwise 1 second.
        private func desiredInterval() -> TimeInterval {
            let remaining = auction.endTime.calculateTimeDifferenceFromNowUTC()
            
            return remaining > 86400 ? 3600 : remaining > 3600 ? 60 : 1
        }
        
        /// Updates the countdown text based on the current time.
        private func updateCountdown() {
            let remaining = auction.endTime.calculateTimeDifferenceFromNowUTC()
            
            if remaining <= 0 {
                countdown = "0 minutes and 0 seconds"
                timer?.invalidate()
                return
            }
            
            if remaining > 86400 {
                // More than 1 day: show day and hours.
                let days = Int(remaining) / 86400
                let hours = (Int(remaining) % 86400) / 3600
                countdown = "\(days) day\(days != 1 ? "s" : "") and \(hours) hour\(hours != 1 ? "s" : "")"
            } else if remaining > 3600 {
                // More than 1 hour: show hours and minutes.
                let hours = Int(remaining) / 3600
                let minutes = (Int(remaining) % 3600) / 60
                countdown = "\(hours) hour\(hours != 1 ? "s" : "") and \(minutes) minute\(minutes != 1 ? "s" : "")"
            } else {
                // Less than 1 hour: show minutes and seconds.
                let minutes = Int(remaining) / 60
                let seconds = Int(remaining) % 60
                countdown = "\(minutes) minute\(minutes != 1 ? "s" : "") and \(seconds) second\(seconds != 1 ? "s" : "")"
            }
        }
        
        
}


#Preview {
    VStack{
        AuctionCardView(
            auction: .init(
                id: UUID(),
                name: "Rick Roll",
                price: "1000",
                coverUrl: "https://s.yimg.com/ny/api/res/1.2/Onq1adoghZAHhpsXXmF8Pw--/YXBwaWQ9aGlnaGxhbmRlcjt3PTEyNDI7aD05MzE-/https://media.zenfs.com/en/insider_articles_922/c6ce8d0b9a7b28f9c2dee8171da98b8f",
                auctionType: .descending,
                bidsCount: 11,
                endTime: .now.advanced(by: 15)
            )
        )
        
        
    }.padding()
}

