//
//  main.swift
//  AppiconText
//
//  Created by Evgeniy Yurtaev on 08/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import AppKit

public enum ArgumentsKeys: String {
    case captionText = "--caption-text"
    case captionFontName = "--caption-font-name"
    case captionFontSize = "--caption-font-size"
    case captionTextColor = "--caption-text-color"
    case captionBackroundColor = "--caption-background-color"
    case appiconName = "--appicon-name"
    case buildPath = "--build-path"
}

public enum EnvironmentKeys: String {
    case targetBuildDir = "TARGET_BUILD_DIR"
    case contentsFolderPath = "CONTENTS_FOLDER_PATH"
    case assetcatalogCompilerAppiconName = "ASSETCATALOG_COMPILER_APPICON_NAME"
}

func run() {
    let processInfo = ProcessInfo.processInfo
    var arguments = processInfo.arguments
        .map { (string) -> (key: String, value: String?) in
            parseArgument(fromString: string)
        }
        .filter({ (argument) -> Bool in
            argument.value != nil
        })
        .reduce([:]) { (acc, argument) -> [String: String] in
            var mutableAcc = acc
            mutableAcc[argument.key] = argument.value
            return mutableAcc
        }

    guard let captionText = arguments[ArgumentsKeys.captionText.rawValue] else {
        return
    }

    let fontName: String? = arguments[ArgumentsKeys.captionFontName.rawValue]
    var fontSize: CGFloat
    if let value = arguments[ArgumentsKeys.captionFontSize.rawValue] {
        guard let fontSizeDouble = Double(value) else {
            print("invalid `\(ArgumentsKeys.captionFontSize.rawValue)` format: \(value)")
            exit(1)
        }
        fontSize = CGFloat(fontSizeDouble)
    } else {
        fontSize = 14
    }
    let font: NSFont
    if let fontName = fontName {
        guard let value = NSFont(name: fontName, size: fontSize) else {
            print("unknown font: \(fontName)")
            exit(1)
        }
        font = value
    } else {
        font = NSFont.systemFont(ofSize: fontSize)
    }

    var captionTextColor: NSColor? = nil
    if let value = arguments[ArgumentsKeys.captionTextColor.rawValue] {
        guard let color = NSColor(hex: value) else {
            print("invalid `\(ArgumentsKeys.captionTextColor.rawValue)` format: \(value)")
            exit(1)
        }
        captionTextColor = color
    }

    var captionBackroundColor: NSColor? = nil
    if let value = arguments[ArgumentsKeys.captionBackroundColor.rawValue] {
        guard let color = NSColor(hex: value) else {
            print("invalid `\(ArgumentsKeys.captionBackroundColor.rawValue)` format: \(value)")
            exit(1)
        }
        captionBackroundColor = color
    }

    let environment = processInfo.environment
    let appiconName: String
    if let value = arguments[ArgumentsKeys.appiconName.rawValue] {
        appiconName = value
    } else if let value = environment[EnvironmentKeys.assetcatalogCompilerAppiconName.rawValue] {
        appiconName = value
    } else {
        print("not found appicon name")
        exit(1)
    }

    let buildPath: String
    if let path = arguments[ArgumentsKeys.buildPath.rawValue] {
        buildPath = path
    } else if let targetBuildDir = environment[EnvironmentKeys.targetBuildDir.rawValue],
        let contentFolderPath = environment[EnvironmentKeys.contentsFolderPath.rawValue] {

        let url = URL(fileURLWithPath: targetBuildDir).appendingPathComponent(contentFolderPath)
        buildPath = url.path
    } else {
        print("not found buiild directory")
        exit(1)
    }

    let iconCaptionProcessor = IconCaption(
        text: captionText,
        font: font,
        textColor: captionTextColor,
        backroundColor: captionBackroundColor
    )
    let appiconsProcessor = AppiconProcessor(iconProcessor: iconCaptionProcessor)

    do {
        print("\(buildPath) \(appiconName)")
        try appiconsProcessor.processIcons(withName: appiconName, directoryPath: buildPath)
    } catch let error as NSError {
        print("icons processing error: \(error)")
        exit(1)
    } catch {
        print("unknown error")
        exit(1)
    }
}

run()
