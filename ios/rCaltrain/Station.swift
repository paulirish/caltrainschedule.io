//
//  Station.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/25/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import Foundation

class Station {

    // Class variables/methods
    private struct StationStruct {
        static var names = NSMutableOrderedSet()
        static var idToStation = [Int: Station]()
        static var nameToStations = [String: [Station]]()
    }

    class func getNames() -> [String] {
        return (StationStruct.names.array as! [String]).sorted(<)
    }
    class func getStation(byId id: Int) -> Station? {
        return StationStruct.idToStation[id]
    }
    class func getStations(byName name: String) -> [Station]? {
        return StationStruct.nameToStations[name]
    }


    // Instance variables/methods
    let name: String
    let id: Int

    init(name: String, id: Int) {
        self.name = name
        self.id = id

        StationStruct.names.addObject(name)
        StationStruct.idToStation[id] = self

        if (StationStruct.nameToStations[name] != nil) {
            StationStruct.nameToStations[name]!.append(self)
        } else {
            StationStruct.nameToStations[name] = [self]
        }
    }

}