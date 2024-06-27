//
//  TTL.swift
//  
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import Foundation

public enum TTL: Codable, Sendable {
    private enum CodingKeys: String, CodingKey {
        case second, minute, hour, day, forever
    }

    case second(Int)
    case minute(Int)
    case hour(Int)
    case day(Int)
    case forever

    public static let `default` = TTL.day(1)

    var value: Int {
        switch self {
        case .second(let seconds):
            return seconds
        case .minute(let minutes):
            return minutes * 60
        case .hour(let hours):
            return hours * 60 * 60
        case .day(let days):
            return days * 60 * 60 * 24
        case .forever:
            return Int.max
        }
    }
}

