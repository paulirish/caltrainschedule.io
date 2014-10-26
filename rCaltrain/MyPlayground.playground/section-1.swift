// Playground - noun: a place where people can play

import UIKit

//
//extension String {
//    subscript(index:Int) -> Character{
//        return self[advance(self.startIndex, index)]
//    }
//
//    subscript (r: Range<Int>) -> String {
//        var start = advance(startIndex, r.startIndex)
//        var end = advance(startIndex, r.endIndex)
//        return substringWithRange(Range(start: start, end: end))
//    }
//
//    var length: Int {
//        get {
//            return countElements(self)
//        }
//    }
//
//    func splits<R : BooleanType>(isSeparator: (Character) -> R, maxSplit: Int = -1, allowEmptySlices: Bool = true) -> [String.SubSlice] {
//        if (maxSplit < 0) {
//            return split(self, isSeparator, allowEmptySlices: allowEmptySlices)
//        } else {
//            return split(self, isSeparator, maxSplit: maxSplit, allowEmptySlices: allowEmptySlices)
//        }
//    }
//    
//}
//
//extension NSDate {
//    convenience init(timeString: String) {
//        let formatter = NSDateFormatter()
//        formatter.dateFormat = "HH:mm:ss"
//        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
//        if let time = formatter.dateFromString(timeString) {
//            self.init(timeInterval: 0, sinceDate: time)
//        } else {
//            // a special case that HH is greater than 23
//            var hour = timeString[0...1].toInt()!
//            if hour > 23 {
//                var newString = String("00" + timeString[2...timeString.length-1])
//                if let time = formatter.dateFromString(newString) {
//                    self.init(timeInterval: NSTimeInterval(hour*60*60), sinceDate: time)
//                } else {
//                    fatalError("Invalid timeString: \(timeString)")
//                }
//            } else {
//                fatalError("Invalid timeString: \(timeString)")
//            }
//        }
//    }
//}

//NSDate(timeString: "09:45:00")
//NSDate(timeString: "12:00:00")
//var a = NSDate(timeString: "23:59:00")
//var b = NSDate(timeString: "24:00:00")
//
//let f = NSDateFormatter()
//f.dateFormat = "HH:mm"
////f.dateStyle = NSDateFormatterStyle.NoStyle
////f.timeStyle = NSDateFormatterStyle.ShortStyle
//
//f.stringFromDate(a)
//f.stringFromDate(b)

let f = NSDateFormatter()
f.dateFormat = "MM/dd/yy"
var str = f.stringFromDate(NSDate())

f.dateFormat = "MM/dd/yy, HH:mm:ss"
f.dateFromString("\(str), 23:59:00")!
