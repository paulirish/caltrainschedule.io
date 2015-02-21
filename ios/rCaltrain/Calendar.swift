//
//  Calendar.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 2/19/15.
//  Copyright (c) 2015 Ranmocy. All rights reserved.
//

import Foundation

class Calendar {

    class var currentCalendar : NSCalendar {
        get { return NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)! }
    }

    private let weekdays : [Bool]
    let start_date, end_date : NSDate!

    init(item: NSArray) {
        assert(item.count == 9, "Expected item has 9 elements")

        // Make sunday as the first day, since we use Gregorian calendar
        var days = [item[6] as Int == 1]
        for index in 0...5 {
            days.append(item[index] as Int == 1)
        }
        weekdays = days

        start_date = NSDate.parseDate(asYYYYMMDDInt: item[7] as Int)
        end_date   = NSDate.parseDate(asYYYYMMDDInt: item[8] as Int)
    }

    // day is in 1...7
    func isValid(weekday day : Int) -> Bool {
        return self.weekdays[day - 1]
    }

}

