//
//  Result.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 2/17/15.
//  Copyright (c) 2015 Ranmocy. All rights reserved.
//

import Foundation

class Result {

    let departureStop: Stop
    let arrivalStop: Stop

    var departureTime: NSDate {
        return departureStop.departureTime
    }
    var arrivalTime: NSDate {
        return arrivalStop.arrivalTime
    }

    private func dateToStr(date: NSDate) -> String {
        let interval = Int(date.timeIntervalSince1970)
        let hours = String(interval / 3600).rjust(2, withStr: "0")
        let minutes = String(interval / 60 % 60).rjust(2, withStr: "0")
        return "\(hours):\(minutes)"
    }

    var departureStr: String {
        return dateToStr(departureTime)
    }
    var arrivalStr: String {
        return dateToStr(arrivalTime)
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