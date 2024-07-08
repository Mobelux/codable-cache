//
//  JSONDecoder+Utils.swift
//  
//
//  Created by Mathew Gacy on 7/8/24.
//

import Foundation

extension JSONDecoder {
    static let iso8601: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return decoder
    }()
}
