//
//  FileManagerExtension.swift
//  AppiconText
//
//  Created by Evgeniy Yurtaev on 08/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import Foundation

public extension FileManager {
    public func files(withPrefix prefix: String, at path: String) -> [String]? {
        guard let enumeration = self.enumerator(atPath: path) else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        return enumeration.filter { (filePath) -> Bool in
            guard let filePath = filePath as? String else {
                return false
            }
            let url = URL(fileURLWithPath: filePath)

            return url.lastPathComponent.hasPrefix(prefix)
        }.map { (fileSubPath) -> String in
            url.appendingPathComponent(fileSubPath as! String).path
        }
    }
}
