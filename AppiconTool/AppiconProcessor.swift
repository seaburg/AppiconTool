//
//  AppiconProcessor.swift
//  AppiconTool
//
//  Created by Evgeniy Yurtaev on 08/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import AppKit

public let AppiconProcessorErrorDomain = "com.appicontool.appicon-processor"

public class AppiconProcessor {
    private let iconProcessor: IconProcessing

    public init(iconProcessor: IconProcessing) {
        self.iconProcessor = iconProcessor
    }

    public func processIcons(withName iconName: String, directoryPath: String) throws {
        let deviceDependentScalePatterd = ".+@(\\d)+x~[^.]+.[^.]+"
        let deviceDependentScaleRegExp = try! NSRegularExpression(
            pattern: deviceDependentScalePatterd,
            options: NSRegularExpression.Options()
        )

        guard let imagePaths = FileManager().files(withPrefix: iconName, at: directoryPath) else {
            throw NSError(domain: AppiconProcessorErrorDomain, code: 0, userInfo: [
                NSLocalizedDescriptionKey: "Build directory with '\(directoryPath)' path does not exist"
            ])
        }

        for path in imagePaths {
            guard let originIcon = NSImage(contentsOfFile: path) else {
                continue
            }
            var contentScale: CGFloat = 1
            if let result = deviceDependentScaleRegExp.firstMatch(in: path, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, path.characters.count)) {
                let range = result.rangeAt(1)
                let start = path.index(path.startIndex, offsetBy: range.location)
                let end = path.index(path.startIndex, offsetBy: range.location + range.length)

                let scaleString = path[start..<end]
                contentScale = CGFloat(Int(scaleString)!)
            }

            let icon = try iconProcessor.process(originIcon, contentScale: contentScale)

            let url = URL(fileURLWithPath: path)
            let pathExtension = url.pathExtension.lowercased()
            let imageType: NSBitmapImageFileType = (pathExtension == "jpg" || pathExtension == "jpeg") ? .JPEG : .PNG

            try icon.save(to: url, type: imageType, compressionFactor: 0)
        }
    }
}
