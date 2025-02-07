//
//  APIin.swift
//  CaravanWebApp
//
//  Created by Tanner Flagg on 2/6/25.
//

import Foundation



struct create_trip_in: Decodable{
    var user_id: UUID
    var trip_id: UUID
    var vehicle_id: UUID
    var vehicle_name: String
    var current_lat: String
    var current_long: String
}

struct join_trip_in: Decodable{
    var trip_id: UUID
    var vehicle_id: UUID
    var user_id: UUID
    var vehicle_name: String
    var current_lat: String
    var current_long: String
}

