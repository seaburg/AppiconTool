//
//  IconProcessing.swift
//  AppiconTool
//
//  Created by Evgeniy Yurtaev on 08/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import AppKit

public protocol IconProcessing {
    func process(_ icon: NSImage, contentScale: CGFloat) throws -> NSImage
}
