//
//  Trip.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/23/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import Foundation

class Trip {

    let id : String
    var stops = [Stop]()

    init(id: String) {
        self.id = id
    }

    convenience init(id: String, stopsArray: NSArray) {
        self.init(id: id)

        // FIXME: can't use `for data in stopsArray as [NSArray]`
        // which will crash when compile as release version
        for data in stopsArray {
            assert(data.count == 2, "data length is \(data.count), expected 2!")

            let stationId = data[0] as Int;
            let time = NSDate(timeIntervalSince1970: NSTimeInterval(data[1] as Int))
            
            if let station = Station.getStation(byId: stationId) {
                self.stops.append(Stop(station: station, departureTime: time, arrivalTime: time))
            } else {
                fatalError("can't find station id\(stationId)")
            }
        }
    }

    func addStop(stop : Stop) -> Trip {
        self.stops.append(stop)
        return self
    }

    func findFrom(from: Station, to: Station) -> (Stop, Stop)? {
        var i: Int = 0
        var fromStop: Stop?, toStop: Stop?

        // find the departure stop
        while (i < stops.count){
            if (stops[i].station === from) {
                fromStop = stops[i]
                break
            }
            i++
        }

        // if missing
        if (fromStop == nil) {
            return nil
        }

        // from and to can't be the same
        i++

        // find the arrival stop
        while (i < stops.count) {
            if (stops[i].station === to) {
                toStop = stops[i]
                break
            }
            i++
        }

        // if missing
        if (toStop == nil) {
            return nil
        }
        
        return (fromStop!, toStop!)
    }

}