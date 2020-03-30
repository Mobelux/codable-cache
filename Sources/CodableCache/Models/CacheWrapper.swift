//
//  CacheWrapper.swift
//  
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import Foundation

struct CacheWrapper<T: Codable>: Codable {
    let ttl: TTL
    let created: Date
    let object: T
}

extension CacheWrapper {
    var isObjectStale: Bool {
        return abs(created.timeIntervalSinceNow) >= TimeInterval(ttl.value)
    }
}
