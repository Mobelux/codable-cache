//
//  CacheWrapper.swift
//
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import DiskCache
import Foundation

public final class CodableCache {
    private lazy var cache: DiskCache = {
        do {
            return try DiskCache(storageType: storageType)
        } catch {
            fatalError("Creating cache instance failed with error:\n\(error)")
        }
    }()

    private lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        return encoder
    }()

    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return decoder
    }()

    public private(set) var storageType: StorageType

    public init(_ storageType: StorageType = .temporary(.custom("codable-cache"))) {
        self.storageType = storageType
    }

    public func cache<T: Codable>(object: T, key: Keyable, ttl: TTL = TTL.default) async throws {
        let wrapper = CacheWrapper(ttl: ttl, created: Date(), object: object)
        try await cache.cache(try encoder.encode(wrapper), key: key.rawValue)
    }

    public func delete(objectWith key: Keyable) async throws {
        try await cache.delete(key.rawValue)
    }

    public func deleteAll() async throws {
        try await cache.deleteAll()
    }

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
