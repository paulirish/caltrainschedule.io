//
//  Service.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/25/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import Foundation

class Service {

    // Class variables/methods
    private struct ServiceStruct {
        static var services = [Service]()
        static var idToServices = [String: [Service]]()
    }

    class func getAllServices() -> [Service] {
        return ServiceStruct.services
    }

    class func getServices(byId id: String) -> [Service]? {
        return ServiceStruct.idToServices[id]
    }

    // Instance variables/methods
    let id : String
    var trips = [String: Trip]()
    var calendar : Calendar!
    var calendar_dates = [CalendarDates]()

    init (id: String) {
        self.id = id
        ServiceStruct.services.append(self)

        if (ServiceStruct.idToServices[id] != nil) {
            ServiceStruct.idToServices[id]!.append(self)
        } else {
            ServiceStruct.idToServices[id] = [self]
        }
    }

    convenience init (id: String, tripsDict : NSDictionary) {
        self.init(id: id)
        
        for (tripId, stopsArray) in tripsDict as! [String: NSArray] {
            self.addTrip(Trip(id: tripId, stopsArray: stopsArray))
        }
    }

    func addTrip(trip: Trip) -> Service {
        self.trips[trip.id] = trip
        return self
    }

    func isValid(atWeekday day: Int) -> Bool {
        let date = NSDate()
        return (calendar.start_date <= date) && (date <= calendar.end_date) && calendar.isValid(weekday: day)
    }

    func isValidAtToday() -> Bool {
        let date = NSDate()
        let day = Calendar.currentCalendar.components(.Weekday, fromDate: date).weekday

        var exceptional_add = false
        var exceptional_remove = false

        // Only Today will consider holiday
        // (inCalendar && not inDates2) || inDates1
        for eDate in calendar_dates {
            if (date.compare(eDate.exception_date) == .OrderedSame) {
                if (eDate.toAdd) {
                    exceptional_add = true
                } else {
                    exceptional_remove = true
                }
            }
        }

        return (isValid(atWeekday: day) && !exceptional_remove) || exceptional_add
    }

    func isValidAtWeekday() -> Bool {
        // weekday is from 2 to 6, sunday is the first day
        for day in 2...6 {
            if (!isValid(atWeekday: day)) {
                return false
            }
        }
        return true
    }

    func isValidAtSaturday() -> Bool {
        return isValid(atWeekday: 7)
    }

    func isValidAtSunday() -> Bool {
        return isValid(atWeekday: 1)
    }

    func isValidAt(withCategory: String) -> Bool {
        switch withCategory {
        case "Now":
            return isValidAtToday()
        case "Weekday":
            return isValidAtWeekday()
        case "Saturday":
            return isValidAtSaturday()
        case "Sunday":
            return isValidAtSunday()
        default:
            return false
        }
    }

}
