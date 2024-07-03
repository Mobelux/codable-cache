//
//  MockCache.swift
//  
//
//  Created by Jeremy Greenwood on 2/23/22.
//

import DiskCache
import Foundation

class MockCache: Cache {
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

    var callable: Callable = .none
    let instruction: Instruction

    func syncCache(_ data: Data, key: String) throws {
        defer {
            self.callable = .cache
        }

        switch instruction {
        case .throw(let error):
            throw error
        case .data(let instructionData):
            guard instructionData == data else {
                throw "mismatched data"
            }
        case .dataThrow:
            fatalError("not callable")
        case .none:
            fatalError("not callable")
        }
    }

    func syncData(_ key: String) throws -> Data {
        defer {
            self.callable = .data
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
            self.callable = .delete
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
            self.callable = .deleteAll
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
