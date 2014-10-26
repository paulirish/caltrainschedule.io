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

//    func stopTime(departure a: String, arrival b: String) -> (NSDate, NSDate)? {
//        var i: Int = 0
//        var aDate: NSDate, bDate: NSDate
//
//        // find the departure stop
//        while (i < stops.count){
//            if (stops[i].0 == a) {
//                break
//            }
//            i++
//        }
//
//        if i >= stops.count { // if missing
//            return nil
//        }
//
//        aDate = stops[i].1
//        i++
//
//        // find the arrival stop
//        while (i < stops.count) {
//            if (stops[i].0 == b) {
//                break
//            }
//            i++
//        }
//
//        if (i >= stops.count) { // if missing
//            return nil
//        }
//
//        bDate = stops[i].1
//
//        return (aDate, bDate)
//    }

}