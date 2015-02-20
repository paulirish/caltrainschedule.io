//
//  Calendar.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 2/19/15.
//  Copyright (c) 2015 Ranmocy. All rights reserved.
//

import Foundation

class Calendar {

    let monday, tuesday, wednesday, thursday, friday, saturday, sunday : Bool
    let start_date, end_date : NSDate!

    init(item: NSArray) {
        assert(item.count == 9, "Expected item has 7 elements")

        monday     = item[0] as Int == 1
        tuesday    = item[1] as Int == 1
        wednesday  = item[2] as Int == 1
        thursday   = item[3] as Int == 1
        friday     = item[4] as Int == 1
        saturday   = item[5] as Int == 1
        sunday     = item[6] as Int == 1
        start_date = NSDate.parseDate(asYYYYMMDDInt: item[7] as Int)
        end_date   = NSDate.parseDate(asYYYYMMDDInt: item[8] as Int)
    }

}

