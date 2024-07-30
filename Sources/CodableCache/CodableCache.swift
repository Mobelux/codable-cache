//
//  CacheWrapper.swift
//
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import DiskCache
import Foundation

/// A cache for `Codable` values.
public final class CodableCache: Sendable {
    private let cache: Cache
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let makeDate: @Sendable () -> Date

    /// Initilizes an instance of `CodableCache`.
    /// - Parameter cache: A type conforming to the `Cache` protocol.
    public convenience init(_ cache: Cache) {
        self.init(cache: cache)
    }

    internal init(
        cache: any Cache,
        decoder: JSONDecoder = .iso8601,
        encoder: JSONEncoder = .iso8601,
        makeDate: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.cache = cache
        self.decoder = decoder
        self.encoder = encoder
        self.makeDate = makeDate
    }

    /// Asynchronously caches the given object.
    /// - Parameter object: The object which should be cached. It must conform to `Codable`.
    /// - Parameter key: A unique key used to identify the cached object.
    /// - Parameter ttl: Defines the amount of time the cached object is valid.
    public func cache<T: Codable>(object: T, key: Keyable, ttl: TTL = TTL.default) async throws {
        let wrapper = CacheWrapper(ttl: ttl, created: makeDate(), object: object)
        try await cache.cache(encoder.encode(wrapper), key: key.rawValue)
    }

    /// Deletes the cached object associated with the given key.
    /// - Parameter key: A unique key used to identify the cached object.
    public func delete(objectWith key: Keyable) async throws {
        try await cache.delete(key.rawValue)
    }

    /// Deletes all cached objects.
    public func deleteAll() async throws {
        try await cache.deleteAll()
    }

    /// Asynchronously gets an object from the cache.
    /// - Returns: An instance of the previously cached object. If the `ttl` has expired or if nothing has been cached for `key`, returns nil.
    public func object<T: Codable>(key: Keyable) async -> T? {
        do {
            let data = try await self.cache.data(key.rawValue)
            let wrapper = try decoder.decode(CacheWrapper<T>.self, from: data)
            if wrapper.isObjectStale {
                try await delete(objectWith: key)
                return nil
            } else {
                return wrapper.object
            }
        } catch let error as NSError {
            switch error.code {
            case NSFileNoSuchFileError, NSFileReadNoSuchFileError:
                return nil
            default:
                try? await delete(objectWith: key)
                return nil
            }
        }
    }
}
