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

    func cache(_ data: Data, key: String) async throws {
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

    func data(_ key: String) async throws -> Data {
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

    func delete(_ key: String) async throws {
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

    func deleteAll() async throws {
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

    func fileURL(_ filename: String) -> URL { fatalError("not callable") }
}
