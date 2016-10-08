//
//  IconCaption.swift
//  AppiconTool
//
//  Created by Evgeniy Yurtaev on 08/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import AppKit

public let IconCaptionErrorDomain = "com.appicontool.icon-caption"

public class IconCaption: IconProcessing {
    private let text: String
    private let font: NSFont

    public init(text: String, font: NSFont = NSFont.systemFont(ofSize: 14)) {
        self.text = text
        self.font = font
    }

    public func process(_ icon: NSImage, contentScale: CGFloat) throws -> NSImage {
        guard let imageRepresentation = icon.bestRepresentation(
            for: NSMakeRect(0, 0, icon.size.width, icon.size.height),
            context: nil,
            hints: nil
        ) else {
            throw NSError(domain: IconCaptionErrorDomain, code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Failed creating image representation from image"
            ])
        }
        if imageRepresentation.pixelsWide < 1 && imageRepresentation.pixelsHigh < 1 {
            return icon
        }

        let bitmapRepresentation = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: imageRepresentation.pixelsWide,
            pixelsHigh: imageRepresentation.pixelsHigh,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSDeviceRGBColorSpace,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!

        NSGraphicsContext.saveGraphicsState()
        let context = NSGraphicsContext(bitmapImageRep: bitmapRepresentation)
        NSGraphicsContext.setCurrent(context)

        let contextPointer = NSGraphicsContext.current()!.graphicsPort
        let cgContext: CGContext = unsafeBitCast(contextPointer, to: CGContext.self)

        let backroundColor: NSColor
        let textColor: NSColor
        if let averageColor = icon.averageColor, averageColor.isBright {
            backroundColor = NSColor(white: 0, alpha: 0.5)
            textColor = NSColor(white: 1, alpha: 0.8)
        } else {
            backroundColor = NSColor(white: 1, alpha: 0.5)
            textColor = NSColor(white: 0, alpha: 0.8)
        }

        let scale = CGFloat(imageRepresentation.pixelsWide) / icon.size.width
        let rect = NSRect(x: 0, y: 0, width: icon.size.width * scale, height: icon.size.height * scale)
        var textRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height * 0.5)

        let scaledFont = NSFont(name: font.fontName, size: font.pointSize * scale * contentScale)!
        let fontHeight = fontAndHeight(forText: text, font:scaledFont, width: textRect.width, maxHeight: textRect.height)
        textRect.size.height = fontHeight.height

        icon.draw(in: rect)
        cgContext.setFillColor(backroundColor.cgColor)
        cgContext.beginPath()
        cgContext.addRect(textRect)
        cgContext.fillPath()

        let paragraphStyle = NSMutableParagraphStyle();
        paragraphStyle.alignment = .center

        (text as NSString).draw(in: textRect, withAttributes: [
            NSFontAttributeName: fontHeight.font,
            NSParagraphStyleAttributeName: paragraphStyle,
            NSForegroundColorAttributeName: textColor,
        ])
        NSGraphicsContext.restoreGraphicsState()

        let resultImage = NSImage(size: icon.size)
        resultImage .addRepresentation(bitmapRepresentation)
        
        return resultImage
    }

    private func fontAndHeight(forText text: String, font: NSFont, width: CGFloat, maxHeight: CGFloat) -> (font: NSFont, height: CGFloat) {
        let nsStringText = (text as NSString)

        var scaledFont = font
        var scaledHeight: CGFloat = 0
        var completed = false

        repeat {
            let bounds = nsStringText.boundingRect(
                with: NSMakeSize(width, CGFloat.greatestFiniteMagnitude),
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSFontAttributeName: scaledFont]
            )
            scaledHeight = bounds.height

            completed = scaledHeight < maxHeight
            if !completed {
                scaledFont = NSFont(name: scaledFont.fontName, size: scaledFont.pointSize - 1)!
            }
        } while !completed && scaledFont.pointSize > 3
        if !completed {
            scaledHeight = maxHeight
        }

        return (scaledFont, scaledHeight)
    }
}
