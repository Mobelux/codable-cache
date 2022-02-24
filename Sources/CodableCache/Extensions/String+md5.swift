//
//  File.swift
//  
//
//  Created by Jeremy Greenwood on 4/8/20.
//

import CryptoKit

extension String {
    var md5: String {
        Insecure.MD5
            .hash(data: data(using: .utf8)!)
            .map { String(format:"%02X", $0) }
            .joined()
            .lowercased()
    }
}
