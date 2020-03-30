//
//  TTL.swift
//  
//
//  Created by Jeremy Greenwood on 3/30/20.
//

import Foundation

public enum TTL: Codable {
    private enum CodingKeys: String, CodingKey {
        case second, minute, hour, day, forever
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let value = try? container.decode(Int.self, forKey: .second) {
            self = .second(value)
            return
        } else if let value = try? container.decode(Int.self, forKey: .minute) {
            self = .minute(value)
            return
        } else if let value = try? container.decode(Int.self, forKey: .hour) {
            self = .hour(value)
            return
        } else if let value = try? container.decode(Int.self, forKey: .day) {
            self = .day(value)
            return
        } else if (try? container.decode(String.self, forKey: .forever)) != nil {
            self = .forever
            return
        }

        throw NSError(domain: "com.mobelux.codable-cache", code: -100, userInfo: [NSLocalizedDescriptionKey: "\(TTL.self) - Decode failure"])
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .second(let time):
            try container.encode(time, forKey: .second)
        case .minute(let time):
            try container.encode(time, forKey: .minute)
        case .hour(let time):
            try container.encode(time, forKey: .hour)
        case .day(let time):
            try container.encode(time, forKey: .day)
        case .forever:
            try container.encode("", forKey: .forever)
        }
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

