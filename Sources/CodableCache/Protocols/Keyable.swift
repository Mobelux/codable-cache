//
//  Keyable.swift
//  
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import Foundation

public protocol Keyable {
    var rawValue: String { get }
}

extension URL: Keyable {
    public var rawValue: String {
        return absoluteString.md5
    }
}

extension String: Keyable {
    public var rawValue: String {
        return md5
    }
}
