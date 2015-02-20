//
//  Service.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/25/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import Foundation

class Service {

    // Class variables/methods
    private struct ServiceStruct {
        static var idToService = [String: Service]()
    }

    class func getService(byId id: String) -> Service? {
        return ServiceStruct.idToService[id]
    }


    // Instance variables/methods
    let id : String
    var trips = [String: Trip]()
    var calendar : Calendar!
    var calendar_dates : CalendarDates!

    init (id: String) {
        self.id = id
        ServiceStruct.idToService[id] = self
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