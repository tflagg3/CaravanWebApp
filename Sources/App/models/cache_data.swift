//
//  cache_data.swift
//  CaravanWebApp
//
//  Created by Tanner Flagg on 2/6/25.
//

import Foundation

struct cached_trip: Codable {
    var vehicles: [cached_vehicle]
}

struct cached_vehicle: Codable {
    var name: String
    var members: [cached_user]
    var last_lat: Double
    var last_long: Double
    var last_update_time: Date
}

struct cached_user: Codable {
    var user_id: UUID
    var IP: String // this may change?
}
