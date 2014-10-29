//
//  Trip.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/23/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

class Trip {
    struct Cache {
        static let formatter = NSDateFormatter(dateFormat: "HH:mm")
    }
    class var timeFormatter: NSDateFormatter {
        return Cache.formatter
    }

    let departureStop: Stop
    let arrivalStop: Stop

    var departureTime: NSDate {
        return departureStop.departureTime
    }
    var arrivalTime: NSDate {
        return arrivalStop.arrivalTime
    }

    var departureStr: String {
        return Trip.timeFormatter.stringFromDate(departureTime)
    }
    var arrivalStr: String {
        return Trip.timeFormatter.stringFromDate(arrivalTime)
    }
    
    var duration: NSTimeInterval {
        return arrivalStop.arrivalTime.timeIntervalSinceDate(departureStop.departureTime)
    }
    var durationInMin: Int {
        return Int(duration) / 60
    }

    init(departure: Stop, arrival: Stop) {
        self.departureStop = departure
        self.arrivalStop = arrival
    }

}