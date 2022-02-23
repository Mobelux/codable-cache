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
        do {
            return try CodableCache(cache())
        } catch {
            fatalError("Creating cache instance failed with error:\n\(error)")
        }
    }()

    private let cache: () throws -> Cache
    private let key: Keyable
    private let ttl: TTL
    private var value: Value?

    public var projectedValue: CodableCaching<Value> { self }

    public func get() async -> Value? {
        let cachedValue: Value? = await codableCache.object(key: key)
        value = cachedValue
        return cachedValue
    }

    public func set(_ value: Value?) async {
        do {
            if value == nil {
                try await codableCache.delete(objectWith: key)
            } else {
                try await codableCache.cache(object: value, key: key, ttl: ttl)
            }

            self.value = value
        } catch let error as NSError {
            switch error.code {
            case NSFileNoSuchFileError, NSFileReadNoSuchFileError: break
            default:
                #if DEBUG
                print("\(#function) - Caching value failed with error:\n\(error)")
                #endif
            }
        }
    }

    public var wrappedValue: Value? {
        get { value }
        set { value = newValue }
    }

    public init(wrappedValue: Value? = nil,
                key: Keyable,
                cache: @escaping () throws -> Cache = { try DiskCache(storageType: .temporary(.custom("codable-cache"))) },
                ttl: TTL = .default) {
        self.value = wrappedValue
        self.key = key
        self.cache = cache
        self.ttl = ttl
    }
}

