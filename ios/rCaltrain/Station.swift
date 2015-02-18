//
//  Station.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/25/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import Foundation

class Station {

    private struct StationStruct {
        static var idToStation = [Int: Station]()
        static var nameToStations = [String: [Station]]()
    }
    class var idToStation : [Int: Station] {
        get { return StationStruct.idToStation }
        set { StationStruct.idToStation = newValue }
    }
    class var nameToStations : [String: [Station]] {
        get { return StationStruct.nameToStations }
        set { StationStruct.nameToStations = newValue }
    }

    let name: String
    let id: Int

    init(name: String, id: Int) {
        self.name = name
        self.id = id
        Station.idToStation[id] = self
        if var stations = StationStruct.nameToStations[name] {
            stations.append(self)
        } else {
            StationStruct.nameToStations[name] = [self]
        }
    }

}