//
//  AppDelegate.swift
//  rCaltrain
//
//  Created by Ranmocy on 9/30/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Trip data
    var stationNames: [String]!
    var nameToStation: [String: [Station]]!
    var idToStation: [Int: Station]!
    var services: [Service]!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // load stops data
        // {stationName: [stationId1, stationId2]}
        stationNames = []
        nameToStation = [:]
        idToStation = [:]

        if let filePath = NSBundle.mainBundle().pathForResource("stops", ofType: "plist") {
            if let stops = NSDictionary(contentsOfFile: filePath) {
                for (name, idsArray) in stops as [String: NSArray] {
                    stationNames.append(name)

                    var stations = [Station]()
                    for id in idsArray as [Int] {
                        var station = Station(name: name, id: id)
                        idToStation[id] = station
                        stations.append(station)
                    }
                    nameToStation[name] = stations
                }
            }
        }

        // sort stationNames
        stationNames.sort(<)


        // load trips data
        // {serviceId: [[stationId, departTime/arrivalTime],...]}
        services = []

        if let filePath = NSBundle.mainBundle().pathForResource("times", ofType: "plist") {
            if let times = NSDictionary(contentsOfFile: filePath) {
                for (serviceId, stopsArray) in times as [String: NSArray] {
                    var stops = [Stop]()
                    for data in stopsArray {
                        assert(data.count == 2, "data length is \(data.count), expected 2!")

                        var id = data[0] as Int;
                        var time = NSDate(timeIntervalSince1970: NSTimeInterval(data[0] as Int))
                        stops.append(Stop(station: idToStation[id]!, departureTime: time, arrivalTime: time))
                    }
                    services.append(Service(id: serviceId, stops: stops))
                }
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


}

