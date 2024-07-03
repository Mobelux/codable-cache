//
//  TTL.swift
//
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import Foundation

/// Specifies the time-to-live for a cached object.
public enum TTL: Codable {
    private enum CodingKeys: String, CodingKey {
        case second, minute, hour, day, forever
    }

    /// A `TTL` representing a given number of seconds.
    case second(Int)
    /// A `TTL` representing a given number of minutes.
    case minute(Int)
    /// A `TTL` representing a given number of hours.
    case hour(Int)
    /// A `TTL` representing a given number of days.
    case day(Int)
    /// A `TTL` representing a cached object that never expires.
    case forever

    /// The default `TTL` value.
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

