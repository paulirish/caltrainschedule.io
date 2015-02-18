//
//  Service.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/25/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

class Service {

    let id : String
    var trips = [String: Trip]()

    init (id: String) {
        self.id = id
    }

    convenience init (id: String, tripsDict : NSDictionary) {
        self.init(id: id)
        
        for (tripId, stopsArray) in tripsDict as [String: NSArray] {
            self.addTrip(Trip(id: tripId, stopsArray: stopsArray))
        }
    }

    func addTrip(trip: Trip) -> Service {
        self.trips[trip.id] = trip
        return self
    }

}