// Playground - noun: a place where people can play

import UIKit

var t = "123"
var d = NSDate()
var calendar = NSCalendar.currentCalendar()
var c = calendar.components(.HourCalendarUnit | .MinuteCalendarUnit | .SecondCalendarUnit, fromDate: d)

var com = NSDateComponents()
com.year = 2015
com.month = 12
com.day = 2
calendar.dateFromComponents(com)
