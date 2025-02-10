//
//  APIout.swift
//  CaravanWebApp
//
//  Created by Tanner Flagg on 2/6/25.
//

import Foundation
import Vapor

struct update_location_out: Content {
    var vehicles: [vehicle_location_out]
}

struct vehicle_location_out: Codable {
    var name: String
    var lat: String
    var long: String
}
