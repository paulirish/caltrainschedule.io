//
//  Stop.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/25/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import Foundation

class Stop {

    let station: Station
    let departureTime: NSDate
    let arrivalTime: NSDate

    var laterThanNow: Bool {
        return departureTime > NSDate.nowTime
    }

    init(station: Station, departureTime dTime: NSDate, arrivalTime aTime: NSDate) {
        self.station = station
        self.departureTime = dTime
        self.arrivalTime = aTime
    }
    
}