//
//  NSImageExtension.swift
//  AppiconText
//
//  Created by Evgeniy Yurtaev on 08/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import AppKit

public let ImageExtensionErrorDomain = "com.appicontext.error.image-extension"

public extension NSImage {
    public func save(to url: URL,type: NSBitmapImageFileType, compressionFactor: Float) throws {
        guard let imageTTFData = self.tiffRepresentation else {
            throw NSError(domain: ImageExtensionErrorDomain, code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Failed creating TTF representation",
            ])
        }
        guard let imageRep = NSBitmapImageRep(data: imageTTFData) else {
            throw NSError(domain: ImageExtensionErrorDomain, code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Failed creating image representation from TTF",
            ])
        }
        guard let imageData = imageRep.representation(using: type, properties: [
            NSImageCompressionFactor: compressionFactor,
        ]) else {
            throw NSError(domain: ImageExtensionErrorDomain, code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Failed creating data from image representation"
            ])
        }
        try imageData.write(to: url, options: NSData.WritingOptions())
    }

    public var averageColor: NSColor? {
        var rect = NSMakeRect(0, 0, self.size.width, self.size.height)
        guard let cgImage = self.cgImage(forProposedRect: &rect, context: nil, hints: nil) else {
            return nil;
        }

        var data = [UInt8](repeating: 0, count: 4)
        let context = CGContext(
            data: &data,
            width: 1, height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        let averageColor = NSColor(
            red: CGFloat(data[0]) / 255,
            green: CGFloat(data[1]) / 255,
            blue: CGFloat(data[2]) / 255,
            alpha: CGFloat(data[3]) / 255
        )

        return averageColor
    }
}
