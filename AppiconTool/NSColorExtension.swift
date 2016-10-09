//
//  NSColorExtension.swift
//  AppiconTool
//
//  Created by Evgeniy Yurtaev on 08/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import AppKit

public extension NSColor {
    public convenience init(number: UInt, hasAlpha: Bool = false) {
        let red, green, blue, alpha: CGFloat

        var number = number
        if hasAlpha {
            alpha = CGFloat(number & 0xff) / 255
            number = number >> 8
        } else {
            alpha = 1
        }
        blue = CGFloat(number & 0xff) / 255
        number = number >> 8

        green = CGFloat(number & 0xff) / 255
        number = number >> 8

        red = CGFloat(number & 0xff) / 255
        number = number >> 8

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    public convenience init?(hex string: String) {
        var canonicalString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()

        if canonicalString.hasPrefix("0x") || canonicalString.hasPrefix("x") {
            canonicalString = string.substring(from: string.range(of: "x")!.upperBound)
        }
        let hasAlphaComponent = (canonicalString.characters.count > 6)

        guard let number = UInt(canonicalString, radix: 16) else {
            return nil
        }
        self.init(number: number, hasAlpha: hasAlphaComponent)
    }

    public var luminance: CGFloat {
        guard let components = self.cgColor.components else {
            return 0
        }
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        if components.count < 4 {
            red = components[0]
            green = components[0]
            blue = components[0]
        } else {
            red = components[0]
            green = components[1]
            blue = components[2]
        }

        return (0.2126 * red + 0.7152 * green + 0.0722 * blue)
    }
    public var isBright: Bool {
        return luminance >= 74
    }
}
