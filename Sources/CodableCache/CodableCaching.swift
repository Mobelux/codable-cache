//
//  CodableCaching.swift
//  
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import Foundation

@propertyWrapper
public struct CodableCaching<Value: Codable> {
    private let codableCache = CodableCache()
    private let key: Keyable
    private let ttl: TTL

    public var wrappedValue: Value? {
        get {
            codableCache.object(key: key)
        }
        set {
            do {
                guard let newValue = newValue else {
                    try codableCache.delete(objectWith: key)
                    return
                }

                try codableCache.cache(object: newValue, key: key, ttl: ttl)
            } catch {
                debugPrint("\(#function) - \(error)")
            }

        }
    }

    public init(key: Keyable, ttl: TTL = .default) {
        self.key = key
        self.ttl = ttl
    }
}
