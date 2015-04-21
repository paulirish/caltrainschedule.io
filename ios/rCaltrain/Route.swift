//
//  Route.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 2/17/15.
//  Copyright (c) 2015 Ranmocy. All rights reserved.
//

import Foundation

class Route {

    private struct RouteStruct {
        static var routesHash = [String: Route]()
    }
    class var allRoutes : [String: Route] {
        get { return RouteStruct.routesHash }
        set { RouteStruct.routesHash = newValue }
    }

    let name : String
    var services = [String: Service]()

    init (name : String) {
        self.name = name
        Route.allRoutes[name] = self
    }

    convenience init (name : String, servicesDict : NSDictionary ) {
        self.init(name: name)

        for (serviceId, tripsDict) in servicesDict as! [String: NSDictionary] {
            self.addService(Service(id: serviceId, tripsDict: tripsDict))
        }
    }

    func addService(service : Service) -> Route {
        self.services[service.id] = service
        return self
    }

}