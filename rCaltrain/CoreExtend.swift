//
//  CoreExtend.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/26/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

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
