// Playground - noun: a place where people can play

import UIKit
//
//var d = NSDate()
//var calendar = NSCalendar.currentCalendar()
//var c = calendar.components(.HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit, fromDate: d)
//var dd = NSDate(timeIntervalSinceNow: 100)
////NSCalendar.compareDate(calendar).(d, toDate: dd, toUnitGranularity: NSCalendarUnit)
//d.compare(dd).rawValue
//dd.compare(d).rawValue
//
//var com = NSDateComponents()
//com.year = 2015
//com.month = 12
//com.day = 2
//calendar.dateFromComponents(com)

var hash = [String : [Int]]()
hash["1"] = [1]
var arr = hash["1"]!
arr.append(2)
arr
hash["1"]