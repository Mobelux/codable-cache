//
//  Keyable.swift
//  
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import Foundation

public protocol Keyable {
    var key: String { get }
}

extension URL: Keyable {
    public var key: String {
        return String(hashValue).md5
    }
}

extension String: Keyable {
    public var key: String {
        return String(hashValue).md5
    }
}
