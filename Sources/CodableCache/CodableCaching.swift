//
//  CodableCaching.swift
//
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import DiskCache
import Foundation

/// A property wrapper type that can read and write a value from and to a cache.
@propertyWrapper
public final class CodableCaching<Value: Codable> {
    private lazy var codableCache: CodableCache = {
        do {
            return try makeCodableCache()
        } catch {
            fatalError("Creating cache instance failed with error:\n\(error)")
        }
    }()

    private let makeCodableCache: @Sendable () throws -> CodableCache
    private let key: Keyable
    private let ttl: TTL

    /// The wrapped value.
    public var wrappedValue: Value?

    /// The projected value.
    public var projectedValue: CodableCaching<Value> { self }

    /// Asynchronously gets the value from the cache. If the `ttl` has expired or if nothing has been cached for `key`, returns nil.
    @discardableResult
    public func get() async -> Value? {
        let cachedValue: Value? = await codableCache.object(key: key)
        wrappedValue = cachedValue
        return cachedValue
    }

    /// Asynchronously caches the given value.
    public func set(_ value: Value?) async {
        do {
            if value == nil {
                try await codableCache.delete(objectWith: key)
            } else {
                try await codableCache.cache(object: value, key: key, ttl: ttl)
            }

            self.wrappedValue = value
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

    /// Initializes an instance of `CodableCaching`.
    /// - Parameters:
    ///   - wrappedValue: A default value.
    ///   - key: A unique key used to identify the cached object.
    ///   - cache: A function defining a type conforming to `Cache` to use as backing storage.
    ///   - ttl: Defines the amount of time the cached object is valid.
    public convenience init(
        wrappedValue: Value? = nil,
        key: Keyable,
        cache: @escaping @Sendable () throws -> any Cache = { try DiskCache(storageType: .temporary(.custom("codable-cache"))) },
        ttl: TTL = .default
    ) {
        self.init(
            wrappedValue: wrappedValue,
            key: key,
            makeCodableCache: { try CodableCache(cache()) },
            ttl: ttl)
    }

    internal convenience init(
        wrappedValue: Value? = nil,
        key: any Keyable,
        cache: @escaping @Sendable () throws -> any Cache,
        encoder: JSONEncoder,
        makeDate: @escaping @Sendable () -> Date,
        ttl: TTL = .default
    ) {
        self.init(
            wrappedValue: wrappedValue,
            key: key,
            makeCodableCache: { try CodableCache(cache: cache(), encoder: encoder, makeDate: makeDate) },
            ttl: ttl)
    }

    internal init(
        wrappedValue: Value? = nil,
        key: any Keyable,
        makeCodableCache: @escaping @Sendable () throws  -> CodableCache,
        ttl: TTL = .default
    ) {
        self.wrappedValue = wrappedValue
        self.key = key
        self.makeCodableCache = makeCodableCache
        self.ttl = ttl
    }
}
