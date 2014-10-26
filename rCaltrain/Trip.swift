//
//  Trip.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/23/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

class Trip {

    let departureStop: Stop
    let arrivalStop: Stop

    let timeFormater = NSDateFormatter()

    var departureTime: String {
        return timeFormater.stringFromDate(departureStop.departureTime)
    }
    var arrivalTime: String {
        return timeFormater.stringFromDate(arrivalStop.arrivalTime)
    }
    var duration: NSTimeInterval {
        return arrivalStop.arrivalTime.timeIntervalSinceDate(departureStop.departureTime)
    }

    init(departure: Stop, arrival: Stop) {
        self.departureStop = departure
        self.arrivalStop = arrival

        timeFormater.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormater.timeStyle = NSDateFormatterStyle.ShortStyle
    }

}