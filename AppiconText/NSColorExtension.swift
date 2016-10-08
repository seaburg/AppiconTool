//
//  NSColorExtension.swift
//  AppiconText
//
//  Created by Evgeniy Yurtaev on 08/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import AppKit

public extension NSColor {
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
