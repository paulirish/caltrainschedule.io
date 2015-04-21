//
//  AppDelegate.swift
//  rCaltrain
//
//  Created by Ranmocy on 9/30/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        // load stops data
        // {stationName: [stationid]}
        for (name, idsArray) in readPlistAsDict("stops") as! [String: NSArray] {
            for id in idsArray as! [Int] {
                Station(name: name, id: id)
            }
        }

        // load routes data
        // {routeID: {serviceId: {tripId: [[stationId, departTime/arrivalTime],...]}}}
        for (routeName, servicesDict) in readPlistAsDict("routes") as! [String: NSDictionary] {
            Route(name: routeName, servicesDict: servicesDict)
        }

        // load calendar data
        // {serviceID: [monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date]}
        for (serviceId, item) in readPlistAsDict("calendar") as! [String: NSArray] {
            if let services = Service.getServices(byId: serviceId) {
                let calendar = Calendar(item: item)
                for service in services {
                    service.calendar = calendar
                }
            } else {
                fatalError("Can't find service \(serviceId) when load calendar.plist.")
            }
        }

        // load calendar_dates data
        // {serviceID: [exception_date,type]}
        for (serviceId, items) in readPlistAsDict("calendar_dates") as! [String: NSArray] {
            if let services = Service.getServices(byId: serviceId) {
                for item in items as! [NSArray] {
                    let dates = CalendarDates(dateInt: item[0] as! Int, toAdd: item[1] as! Int == 1)
                    for service in services {
                        service.calendar_dates.append(dates)
                    }
                }
            } else {
                fatalError("Can't find service \(serviceId) when load calendar_dates.plist")
            }
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func readPlistAsDict(name: String) -> NSDictionary {
        if let filePath = NSBundle.mainBundle().pathForResource(name, ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: filePath) {
                return dict
            } else {
                fatalError("Can't read plist file \(name)!")
            }
        } else {
            fatalError("Can't find plist file \(name)!")
        }
    }

}

