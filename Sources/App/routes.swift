import Vapor

func routes(_ app: Application) throws {
    
    let decoder = JSONDecoder()
    
    app.get { req async in
        "Welcome to Caravan!"
    }
    
    // is_active
    let is_active = app.grouped("is_active")
    is_active.post { req in
        let cache = req.application.cache
        if let body = req.body.data {
            let params = try decoder.decode(is_active_in.self, from: body)
            do {
                guard let trip: cached_trip = try await cache.get(params.trip_id.description) else {
                    let output = is_active_out(is_active: false)
                    return output
                }
                let output = is_active_out(is_active: true)
                return output
            }
        }
        throw Abort(.unauthorized)
    }
    
    // send_location
    let send_location = app.grouped("send_location")
    send_location.post { req in
        let cache = req.application.cache
        if let body = req.body.data {
            let params = try decoder.decode(update_location_in.self, from: body)
            let ip = req.remoteAddress!.description
            do {
                guard let user: cached_user = try await cache.get(params.user_id.description) else {
                    throw Abort(.unauthorized, reason: "Could not find the user")
                }
                let new_user = cached_user(user_id: params.user_id, IP: ip, vehicle_id: user.vehicle_id, trip_id: user.trip_id)
                guard let vehicle: cached_vehicle = try await cache.get(new_user.vehicle_id.description) else {
                    throw Abort(.unauthorized, reason: "Could not find the vehicle")
                }
                let new_vehicle = cached_vehicle(name: vehicle.name,
                                                 members: vehicle.members,
                                                 last_lat: Double(params.current_lat)!,
                                                 last_long: Double(params.current_long)!,
                                                 last_update_time: Date())
                
                // make sure trip exists before caching our data
                guard let trip: cached_trip = try await cache.get(user.trip_id.description) else {
                    throw Abort(.unauthorized, reason: "Could not find the trip")
                }
                
                try await cache.set(params.user_id.description, to: new_user)
                try await cache.set(user.vehicle_id.description, to: new_vehicle)
                
                // now we have to return the locations
                var vehicle_locations: [vehicle_location_out] = []
                for vehicle in trip.vehicles {
                    let vehicle_out = vehicle_location_out(name: vehicle.name, lat: vehicle.last_lat.description, long: vehicle.last_long.description)
                    vehicle_locations.append(vehicle_out)
                }
                let output = update_location_out(vehicles: vehicle_locations)
                return output
                
            }
        }
        throw Abort(.unauthorized)
    }
    
    // create_trip
    let create_trip = app.grouped("create_trip")
    create_trip.post{ req in
        let cache = req.application.cache
        // first we get all the data:  IP and body
        if let body = req.body.data {
            let params = try decoder.decode(create_trip_in.self, from: body)
            let ip = req.remoteAddress!.description
            
            // create the user with the IP and the Token
            let user = cached_user(user_id: params.user_id, IP: ip, vehicle_id: params.vehicle_id, trip_id: params.trip_id)
            try await cache.set(params.user_id.description, to: user)
            
            // create the vehicle
            let vehicle = cached_vehicle(name: params.vehicle_name,
                                         members: [user],
                                         last_lat: Double(params.current_lat)!,
                                         last_long: Double(params.current_long)!,
                                         last_update_time: Date()
            )
            try await cache.set(params.vehicle_id.description, to: vehicle)
            
            // create the trip
            let trip = cached_trip(vehicles: [vehicle])
            try await cache.set(params.trip_id.description, to: trip)
            
            // return value of nothing
            return "created a trip by user \(params.user_id) at IP: \(ip) with trip id \(params.trip_id) and vehicle \(params.vehicle_name)"
        }
        return "Failed"
    }
    
    
    // join_trip
    let join_trip = app.grouped("join_trip")
    join_trip.post { req in
        let cache = req.application.cache
        if let body = req.body.data {
            let params = try decoder.decode(join_trip_in.self, from: body)
            let ip = req.remoteAddress!.description
            do {
                // make sure that the trip exists
                let user = cached_user(user_id: params.user_id, IP: ip, vehicle_id: params.vehicle_id, trip_id: params.trip_id)
                guard let trip: cached_trip = try await cache.get(params.trip_id.description) else {
                    return "Trip does not exist in cache"
                }
                if let vehicle: cached_vehicle = try await cache.get(params.vehicle_id.description){
                    // the vehicle already exists
                    var members = [user]
                    for vehicle_user in vehicle.members {
                        members.append(vehicle_user)
                    }
                    let new_vehicle = cached_vehicle(name: vehicle.name,
                                                     members: members,
                                                     last_lat: Double(params.current_lat)!,
                                                     last_long: Double(params.current_long)!,
                                                     last_update_time: Date())
                    
                    try await cache.set(params.vehicle_id.description, to: new_vehicle)
                    try await cache.set(params.user_id.description, to: user)
                    return "\(user.user_id) joined the trip \(params.trip_id) in the vehicle \(new_vehicle.name)"
                } else {
                    let new_vehicle = cached_vehicle(name: params.vehicle_name,
                                                     members: [user],
                                                     last_lat: Double(params.current_lat)!,
                                                     last_long: Double(params.current_long)!,
                                                     last_update_time: Date())
                    var vehicles = [new_vehicle]
                    for vehicle in trip.vehicles {
                        vehicles.append(vehicle)
                    }
                    let new_trip = cached_trip(vehicles: vehicles)
                    try await cache.set(params.vehicle_id.description, to: new_vehicle)
                    try await cache.set(params.user_id.description, to: user)
                    try await cache.set(params.trip_id.description, to: new_trip)
                    return "\(user.user_id) joined the trip \(params.trip_id) in the vehicle \(new_vehicle.name)"
                }
                
                
                
                
            }
            
        
            
        }
        return "failed"
    }
    
    // send_notification
    
}
