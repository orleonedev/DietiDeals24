//
//  AuctionImage.swift
//  DietiDeals24
//
//  Created by Oreste Leone on 3/7/25.
//

import SwiftUI
import UIKit

struct AuctionImage:Hashable, Transferable {
    
    enum TransferError: Error {
        case importFailed
    }
    
    let image: Image
    let identifier: UUID = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
        #if canImport(AppKit)
            guard let nsImage = NSImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(nsImage: nsImage)
            return AuctionImage(image: image)
        #elseif canImport(UIKit)
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            let image = Image(uiImage: uiImage)
            return AuctionImage(image: image)
        #else
            throw TransferError.importFailed
        #endif
        }
    }
    
}
