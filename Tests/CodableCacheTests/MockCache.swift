//
//  MockCache.swift
//  
//
//  Created by Jeremy Greenwood on 2/23/22.
//

import DiskCache
import Foundation

final class MockCache: Cache, @unchecked Sendable {
    enum Callable {
        case cache
        case data
        case delete
        case deleteAll
        case none
    }

    enum Instruction {
        case `throw`(Error)
        case data(Data)
        case dataThrow(Data, Error)
        case none
    }

    init(instruction: Instruction) {
        self.instruction = instruction
    }

    private let lock = NSLock()
    var callable: Callable = .none
    let instruction: Instruction

    func syncCache(_ data: Data, key: String) throws {
        defer {
            setCallable(.cache)
        }

        switch instruction {
        case .throw(let error):
            throw error
        case .data(let instructionData):
            guard instructionData == data else {
                throw """
                    mismatched data
                    E: \(String(decoding: instructionData, as: UTF8.self))
                    A: \(String(decoding: data, as: UTF8.self))
                    """
            }
        case .dataThrow:
            fatalError("not callable")
        case .none:
            fatalError("not callable")
        }
    }

    func syncData(_ key: String) throws -> Data {
        defer {
            setCallable(.data)
        }

        switch instruction {
        case .throw(let error):
            throw error
        case .data(let data):
            return data
        case let .dataThrow(data, _):
            return data
        case .none:
            fatalError("not callable")
        }
    }

    func syncDelete(_ key: String) throws {
        defer {
            setCallable(.delete)
        }

        switch instruction {
        case .throw(let error):
            throw error
        case .data:
            fatalError("not callable")
        case let .dataThrow(_, error):
            throw error
        case .none: break
        }
    }

    func syncDeleteAll() throws {
        defer {
            setCallable(.deleteAll)
        }

        switch instruction {
        case .throw(let error):
            throw error
        case .data:
            fatalError("not callable")
        case .dataThrow:
            fatalError("not callable")
        case .none: break
        }
    }

    // MARK: - Async support

    func cache(_ data: Data, key: String) async throws {
        try syncCache(data, key: key)
    }

    func data(_ key: String) async throws -> Data {
        try syncData(key)
    }

    func delete(_ key: String) async throws {
        try syncDelete(key)
    }

    func deleteAll() async throws {
        try syncDeleteAll()
    }

    func fileURL(_ filename: String) -> URL { fatalError("not callable") }
}

private extension MockCache {
    func setCallable(_ value: Callable) {
        lock.lock()
        self.callable = value
        lock.unlock()
    }
}
