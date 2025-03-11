//
//  AuctionDetailView.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/2/25.
//

import SwiftUI

struct AuctionDetailView: View {
    
    let auction: AuctionDetailModel
    let isPersonalAuction: Bool
    @State private var countdown: String = "00:00:00"
    @State private var timer: Timer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            horizontalImageStack(images: auction.images)
            VStack(alignment: .leading, spacing: 32) {
                tagHorizontalStack(auction: auction)
                priceStack(auction.currentPrice)
                timerAndThresholdStack(threshold: auction.threshold)
                if isPersonalAuction, let secrePrice = auction.secretPrice, auction.auctionType == .descending {
                    secrePriceRow(secrePrice)
                }
                descriptionView()
            }
            .padding(.horizontal)
        }
        .onChange(of: auction) { old, newValue in
            self.scheduleTimer()
            self.updateCountdown()
        }
        .onAppear {
            self.scheduleTimer()
            self.updateCountdown()
        }
        .onDisappear {
            self.timer?.invalidate()
        }
    }
}


extension AuctionDetailView {
    
    @ViewBuilder
    func tagHorizontalStack(auction: AuctionDetailModel) -> some View {
        HStack(spacing: 12) {
                Text(auction.category.label)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(10)
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                    .background{Color.accent.brightness(-0.2)}
                    .clipShape(.capsule)
            
            Text(auction.auctionType.label)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(10)
                .padding(.horizontal)
                .foregroundStyle(.white)
                .background{Color.accent.brightness(-0.2)}
                .clipShape(.capsule)
        }
    }
    
    @ViewBuilder
    func secrePriceRow(_ secretPrice: Double) -> some View {
        HStack {
            Text("Secret Price")
                .font(.body)
            Spacer()
            Text("\(secretPrice.formatted()) €")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.accent)
        }
        .padding()
        .background(.secondary.quinary)
        .clipShape(.rect(cornerRadius: 12))
    }
    
    @ViewBuilder
    func priceStack(_ price: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Price")
                .font(.body)
            Text("\(price.formatted()) €")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.accent)
        }
    }
    
    @ViewBuilder
    func timerAndThresholdStack(threshold: Double) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Remaining Time")
                    .font(.body)
                Spacer()
                Text(countdown)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(.easeInOut, value: countdown)
            }
            HStack {
                Text("Threshold")
                    .font(.body)
                Spacer()
                Text("\(threshold.formatted()) €")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.accent)
            }
        }
    }
    
    @ViewBuilder
    func descriptionView() -> some View {
        VStack(alignment: .leading, spacing: 12){
            Text("Description")
                .font(.headline)
            
            Text(auction.description)
                .font(.body)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.secondary.quinary)
                .clipShape(.rect(cornerRadius: 12))
        }
        
    }
    
    @ViewBuilder
    func horizontalImageStack(images: [String] ) -> some View {
        if images.isEmpty {
            GeometryReader { proxy in
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(32)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .clipShape(.rect(cornerRadius: 12))
                    .foregroundStyle(.secondary)
            }
            .frame(height: 192)
            .aspectRatio(1.77, contentMode: .fit)
            .background(.secondary.quaternary)
            .clipShape(.rect(cornerRadius: 24))
            .padding()
            
        } else {
            ScrollView(.horizontal) {
                HStack(spacing: 24) {
                    ForEach(images, id: \.self) { image in
                        GeometryReader { proxy in
                            RemoteImage(urlString: image)
                                .frame(width: proxy.size.width, height: proxy.size.height)
                                .clipped()
                                .clipShape(.rect(cornerRadius: 12))
                        }
                        .aspectRatio(1.77, contentMode: .fit)
                    }
                }
                .padding()
            }
            .scrollIndicators(.never)
            .frame(height: 192)
        }
    }
}

extension AuctionDetailView {
    
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
            let endTimeInterval = auction.endTime.timeIntervalSinceNow
            let corrector: TimeInterval = endTimeInterval > 86400 ? 60*60 : 60
            let remaining = auction.endTime.timeIntervalSinceNow-corrector
            
            return remaining > 86400 ? 3600 : remaining > 3600 ? 60 : 1
        }
        
        /// Updates the countdown text based on the current time.
        private func updateCountdown() {
            let now = Date()
            let remaining = auction.endTime.timeIntervalSince(now)
            
            if remaining <= 0 {
                countdown = "0 minutes and 0 seconds"
                timer?.invalidate()
                return
            }
            
            if remaining > 86400 {
                // More than 1 day: show day and hours.
                let days = Int(remaining) / 86400
                let hours = (Int(remaining) % 86400) / 3600
                countdown = "\(days) day\(days != 1 ? "s" : ""), \(hours)h"
            } else if remaining > 3600 {
                // More than 1 hour: show hours and minutes.
                let hours = Int(remaining) / 3600
                let minutes = (Int(remaining) % 3600) / 60
                countdown = "\(hours)h \(minutes)m"
            } else {
                // Less than 1 hour: show minutes and seconds.
                let minutes = Int(remaining) / 60
                let seconds = Int(remaining) % 60
                countdown = "\(minutes)m \(seconds)s"
            }
        }
}

#Preview {
    NavigationStack{
        AuctionDetailView(
            auction: AuctionDetailModel(
                id: UUID(),
                title: "Title",
                description: "long description ",
                category: .Furniture,
                images: [],
                auctionType: .incremental,
                currentPrice: 12345.0,
                threshold: 123.0,
                timer: 12,
                secretPrice: nil,
                endTime: .now.advanced(by: 60*60),
                vendor: VendorAuctionDetail(id: UUID(), name: "Test", username: "Test", email: "test@test.com", successfulAuctions: 0, joinedSince: .now)
            ), isPersonalAuction: false
        )
    }
}
