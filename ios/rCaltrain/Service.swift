//
//  Service.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/25/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

class Service {

    let category: String
    let stops: [Stop]

    init(id: String, stops: [Stop]) {
        let parts = id.splits({$0 == "-"}, allowEmptySlices: false)
        assert(parts.count == 3, "invalid service id, since no '-' in it.")

        self.category = parts[0]
        self.stops = stops
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