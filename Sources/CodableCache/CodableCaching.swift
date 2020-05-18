//
//  CodableCaching.swift
//  
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import DiskCache
import Foundation

@propertyWrapper
public final class CodableCaching<Value: Codable> {
    private lazy var codableCache: CodableCache = {
        CodableCache(self.storageType)
    }()

    private let key: Keyable
    private let storageType: StorageType
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
            } catch(let error as NSError) {
                switch error.code {
                case NSFileNoSuchFileError: break
                default:
                    debugPrint("\(#function) - \(error)")
                }
            }

        }
    }

    public init(key: Keyable, storageType: StorageType = .temporary(.custom("codable-cache")), ttl: TTL = .default) {
        self.key = key
        self.storageType = storageType
        self.ttl = ttl
    }

    public init(wrappedValue: Value?, key: Keyable, storageType: StorageType = .temporary(.custom("codable-cache")), ttl: TTL = .default) {
        self.key = key
        self.storageType = storageType
        self.ttl = ttl
        self.wrappedValue = wrappedValue
    }
}
