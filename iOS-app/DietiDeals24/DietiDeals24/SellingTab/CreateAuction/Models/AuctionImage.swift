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
    let data: Data
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
        #if canImport(AppKit)
            guard let nsImage = NSImage(data: data) else {
                throw TransferError.importFailed
            }
            // check trasformazione in jpeg per appkit
            let image = Image(nsImage: nsImage)
            return AuctionImage(image: image, data: data)
        #elseif canImport(UIKit)
            guard let uiImage = UIImage.downsampleImage(from: data, maxSize: 1800), let jpegData = uiImage.jpegData(compressionQuality: 1) else {
                throw TransferError.importFailed
            }
//            guard let uiImage = UIImage(data: data), let jpegData = uiImage.jpegData(compressionQuality: 1) else {
//                throw TransferError.importFailed
//            }
            let image = Image(uiImage: uiImage)
            return AuctionImage(image: image, data: jpegData)
        #else
            throw TransferError.importFailed
        #endif
        }
    }
    
}
