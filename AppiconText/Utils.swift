//
//  Utils.swift
//  AppiconTool
//
//  Created by Evgeniy Yurtaev on 09/10/2016.
//  Copyright © 2016 Evgeniy Yurtaev. All rights reserved.
//

import Foundation

func parseArgument(fromString string: String) -> (key: String, value: String?) {
    enum State {
        case text
        case quote(Character)
        case backslash
    }

    var state = State.text
    var isKeyPart = true

    var key = String()
    var value = String()

    for character in string.characters {
        switch state {
        case .text:
            switch character {
            case "\\":
                state = .backslash
                continue
            case "=":
                if isKeyPart {
                    isKeyPart = false
                    continue
                }
            case "\"", "'":
                state = .quote(character)
                continue
            default:
                break
            }
        case .quote(let quoteCharacter):
            if character == quoteCharacter {
                state = .text
            }
        case .backslash:
            state = .text
        }
        if isKeyPart {
            key.append(character)
        } else {
            value.append(character)
        }
    }

    return (
        key,
        isKeyPart ? nil : value
    )
}
