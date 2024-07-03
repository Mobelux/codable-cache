//
//  Keyable.swift
//
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import Foundation

/// A class of types that can be used as a key in a cache.
public protocol Keyable {
    /// The raw value of the key.
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
