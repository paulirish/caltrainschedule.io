//
//  CoreExtend.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/26/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

// Regexp
prefix operator / { }
prefix func /(pattern:String) -> NSRegularExpression {
    return NSRegularExpression(pattern: pattern, options: nil, error: nil)!
}
infix operator / {}
func / (regexp: NSRegularExpression, optionStr: String) -> NSRegularExpression {
    var options: UInt = 0
    for char in Array(optionStr) {
        switch char {
        case "g":
            options += NSRegularExpressionOptions.AnchorsMatchLines.rawValue
        case "s":
            options += NSRegularExpressionOptions.AllowCommentsAndWhitespace.rawValue
        case "i":
            options += NSRegularExpressionOptions.CaseInsensitive.rawValue
        case "m":
            options += NSRegularExpressionOptions.DotMatchesLineSeparators.rawValue
        case "M":
            options += NSRegularExpressionOptions.IgnoreMetacharacters.rawValue
        case "u":
            options += NSRegularExpressionOptions.UseUnixLineSeparators.rawValue
        case "U":
            options += NSRegularExpressionOptions.UseUnicodeWordBoundaries.rawValue
        default:
            println("Unknown regexp options: \(char)")
        }
    }
    return NSRegularExpression(pattern: regexp.pattern, options: NSRegularExpressionOptions(options), error: nil)!
}
infix operator =~ { }
func =~ (string: String, regex: NSRegularExpression!) -> Bool {
    let matches = regex.numberOfMatchesInString(string, options: nil, range: NSMakeRange(0, string.length))
    return matches > 0
}
func =~ (regex: NSRegularExpression?, str: String) -> Bool {
    return str =~ regex
}

extension String {
    subscript(index:Int) -> Character{
        return self[advance(self.startIndex, index)]
    }

    subscript (r: Range<Int>) -> String {
        var start = advance(startIndex, r.startIndex)
        var end = advance(startIndex, r.endIndex)
        return substringWithRange(Range(start: start, end: end))
    }

    var length: Int {
        get {
            return countElements(self)
        }
    }

    func splits<R : BooleanType>(isSeparator: (Character) -> R, maxSplit: Int = -1, allowEmptySlices: Bool = true) -> [String.SubSlice] {
        if (maxSplit < 0) {
            return split(self, isSeparator, allowEmptySlices: allowEmptySlices)
        } else {
            return split(self, isSeparator, maxSplit: maxSplit, allowEmptySlices: allowEmptySlices)
        }
    }
    
}


func < (left: NSDate, right: NSDate) -> Bool {
    return left.timeIntervalSinceDate(right) < 0
}
func > (left: NSDate, right: NSDate) -> Bool {
    return left.timeIntervalSinceDate(right) > 0
}
func == (left: NSDate, right: NSDate) -> Bool {
    return left.timeIntervalSinceDate(right) == 0
}
extension NSDate {
    convenience init(timeStringSinceToday timeString: String) {
        // generate today's date string
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yy"
        var todayStr = formatter.stringFromDate(NSDate())

        formatter.dateFormat = "MM/dd/yy, HH:mm:ss"

        if let time = formatter.dateFromString("\(todayStr), \(timeString)") {
            self.init(timeInterval: 0, sinceDate: time)
        } else {
            // a special case that HH is greater than 23
            var hour = timeString[0...1].toInt()!
            if hour <= 23 {
                fatalError("Invalid timeString: \(timeString)")
            }

            var newString = String("00" + timeString[2...timeString.length-1])
            if let time = formatter.dateFromString("\(todayStr), \(newString)") {
                self.init(timeInterval: NSTimeInterval(hour * 60 * 60), sinceDate: time)
            } else {
                fatalError("Invalid timeString: \(timeString)")
            }
        }
    }
}

extension NSDateFormatter {
    convenience public init(dateFormat: String!) {
        self.init()
        self.dateFormat = dateFormat
    }
    class func weekDayOf(Date: NSDate) -> Int? {
        return NSDateFormatter(dateFormat: "e").stringFromDate(Date).toInt()
    }
}
