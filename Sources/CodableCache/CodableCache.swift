//
//  CacheWrapper.swift
//
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import DiskCache
import Foundation

public final class CodableCache {
    internal static var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        return encoder
    }()

    internal static var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return decoder
    }()

    internal static var makeDate: () -> Date = { Date() }

    private let cache: Cache

    /// Initilizes an instance of `CodableCache`.
    /// - Parameter cache: A type conforming to the `Cache` protocol.
    public init(_ cache: Cache) {
        self.cache = cache
    }

    /// Asynchronously caches the given object.
    /// - Parameter object: The object which should be cached. It must conform to `Codable`.
    /// - Parameter key: A unique key used to identify the cached object.
    /// - Parameter ttl: Defines the amount of time the cached object is valid.
    public func cache<T: Codable>(object: T, key: Keyable, ttl: TTL = TTL.default) async throws {
        let wrapper = CacheWrapper(ttl: ttl, created: Self.makeDate(), object: object)
        try await cache.cache(Self.encoder.encode(wrapper), key: key.rawValue)
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
            let wrapper = try Self.decoder.decode(CacheWrapper<T>.self, from: data)
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
