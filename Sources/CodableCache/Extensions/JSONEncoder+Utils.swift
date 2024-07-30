//
//  JSONEncoder+Utils.swift
//
//
//  Created by Mathew Gacy on 7/8/24.
//

import Foundation

extension JSONEncoder {
    static let iso8601: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        return encoder
    }()

    static let sorted: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys

        return encoder
    }()
}
