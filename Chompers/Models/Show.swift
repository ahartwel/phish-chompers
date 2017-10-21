//
//  Show.swift
//  Chompers
//
//  Created by Alex Hartwell on 10/8/17.
//  Copyright © 2017 ahartwel. All rights reserved.
//

import Foundation

struct ShowsResponse: Codable {
    var data: [Show]
}

struct ShowResponse: Codable {
    var data: Show
}

struct Show: Codable, Equatable {
    static func ==(lhs: Show, rhs: Show) -> Bool {
        return lhs.id == rhs.id
    }
    var id: Int
    var date: String
    var duration: TimeInterval
    ///is soundboard
    var sbd: Bool
    var remastered: Bool
    var tour_id: Int
    var venue_id: Int?
    var likes_count: Int
    var taper_notes: String?
    var venue_name: String?
    var location: String?
    var tags: [String]?
    var venue: Venue?
    var tracks: [Track]?
    var sortedTracks: [Track]? {
        return self.tracks?.sorted(by: { track1, track2 -> Bool in
            return track1.set < track2.set && track1.position < track2.position
        })
    }
    var isDownloaded: Bool? = false
    
}

extension Show {
    var title: String {
        let venueName = self.venue_name ?? (self.venue?.name ?? "")
        return "\(self.date) - \(venueName)"
    }
}

struct Venue: Codable {
    var id: Int
    var name: String
    var latitude: Double
    var longitude: Double
    var shows_count: Int
    var location: String
    var slug: String
}

struct Track: Codable, Equatable {
    static func ==(lhs: Track, rhs: Track) -> Bool {
        return lhs.id == rhs.id
    }
    var id: Int
    var title: String
    var position: Int
    var duration: TimeInterval
    var set: String
    var set_name: String
    var likes_count: Int
    var slug: String
    var mp3: String
    var link: URL? {
        return URL(string: self.mp3)
    }
    var durationString: String {
        let float = Float(self.duration / 1000)
        return float.getTimeString()
    }
    var song_ids: [Int]
}
