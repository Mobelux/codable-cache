//
//  CacheWrapper.swift
//
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import DiskCache
import Foundation

public final class CodableCache {
    private lazy var cache = try! DiskCache(storageType: .temporary(.custom("codable-cache")))
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

    public init() {}

    public func cache<T: Codable>(object: T, key: Keyable, ttl: TTL = TTL.default) throws {
        let wrapper = CacheWrapper(ttl: ttl, created: Date(), object: object)
        try cache.cache(try encoder.encode(wrapper), key: key.key)
    }

    public func delete(objectWith key: Keyable) throws {
        try cache.delete(key.key)
    }

    public func deleteAll() throws {
        try cache.deleteAll()
    }

    public func object<T: Codable>(key: Keyable) -> T? {
        do {
            guard let data = try self.cache.data(key.key) else {
                return nil
            }

            let wrapper = try decoder.decode(CacheWrapper<T>.self, from: data)
            if wrapper.isObjectStale {
                try self.delete(objectWith: key)
                return nil
            } else {
                return wrapper.object
            }
        } catch {
            try? self.delete(objectWith: key)
            return nil
        }
    }
}
