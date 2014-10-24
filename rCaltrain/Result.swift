//
//  Result.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/23/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

class Result {

    let departureDate: NSDate
    let arrivalDate: NSDate

    let timeFormater = NSDateFormatter()

    var departureTime: String {
        return timeFormater.stringFromDate(departureDate)
    }
    var arrivalTime: String {
        return timeFormater.stringFromDate(arrivalDate)
    }
    var duration: Int {
        return Int(arrivalDate.timeIntervalSinceDate(departureDate))
    }

    init (departureTime dTime: NSDate, arrivalTime aTime: NSDate) {
        self.departureDate = dTime
        self.arrivalDate = aTime

        timeFormater.dateStyle = NSDateFormatterStyle.NoStyle
        timeFormater.timeStyle = NSDateFormatterStyle.ShortStyle
    }

}