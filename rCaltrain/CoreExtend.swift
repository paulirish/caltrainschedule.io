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
    convenience init(timeString: String) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        if let time = formatter.dateFromString(timeString) {
            self.init(timeInterval: 0, sinceDate: time)
        } else {
            // a special case that HH is greater than 23
            var hour = timeString[0...1].toInt()!
            if hour > 23 {
                var newString = String("00" + timeString[2...timeString.length-1])
                if let time = formatter.dateFromString(newString) {
                    self.init(timeInterval: NSTimeInterval(hour*60*60), sinceDate: time)
                } else {
                    fatalError("Invalid timeString: \(timeString)")
                }
            } else {
                fatalError("Invalid timeString: \(timeString)")
            }
        }
    }
}
