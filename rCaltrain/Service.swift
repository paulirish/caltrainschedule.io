//
//  Service.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/25/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

class Service {

    let id: String!
    let stops: [Stop]

    init(id: String, stops: [Stop]) {
        self.id = id
        self.stops = stops
    }

}