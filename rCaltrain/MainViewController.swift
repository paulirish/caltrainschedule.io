//
//  MainViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 9/30/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var departurePlaceholder: String = "Departure"
    var arrivalPlaceholder: String = "Arrival"
    var appDelegate: AppDelegate!

    @IBOutlet var departureButton: UIButton!
    @IBOutlet var arrivalButton: UIButton!
    @IBOutlet var whenButton: UISegmentedControl!
    @IBOutlet var reverseButton: UIButton!
    @IBOutlet var resultsTableView: ResultTableView!

    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            println("unwind:" + id + "!")
            updateResults()
        }
    }

    @IBAction func reversePressed(sender: UIButton) {
        let departureTitle = departureButton.currentTitle
        let arrivalTitle = arrivalButton.currentTitle

        if arrivalTitle == arrivalPlaceholder {
            departureButton.setTitle(departurePlaceholder, forState: UIControlState.Normal)
        } else {
            departureButton.setTitle(arrivalTitle, forState: UIControlState.Normal)
        }

        if departureTitle == departurePlaceholder {
            arrivalButton.setTitle(arrivalPlaceholder, forState: UIControlState.Normal)
        } else {
            arrivalButton.setTitle(departureTitle, forState: UIControlState.Normal)
        }

        updateResults()
    }

    @IBAction func whenChanged(sender: UISegmentedControl) {
        var selectedWhen = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        println("whenChanged:\(selectedWhen)")
        updateResults()
    }

    override func viewDidLoad() {
        println("mainDidLoad")

        // save placeholder
        if let title = departureButton.currentTitle {
            departurePlaceholder = title
        }

        if let title = arrivalButton.currentTitle {
            arrivalPlaceholder = title
        }

        // setups
        resultsTableView.dataSource = resultsTableView
        appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        super.viewDidLoad()
    }

    func getInputs() -> ([Station], [Station], String, Bool)? {
        let stationNameToStation = appDelegate.stationNameToStation
        var departureStations: [Station]
        var arrivalStations: [Station]
        var category: String
        var isNow: Bool = false

        // if some input is missing, return nil
        if let dName = departureButton.currentTitle {
            if (stationNameToStation[dName] != nil) {
                departureStations = stationNameToStation[dName]!
            } else {
                return nil
            }
        } else {
            fatalError("departureButton's title is missing!")
        }

        if let aName = arrivalButton.currentTitle {
            if (stationNameToStation[aName] != nil) {
                arrivalStations = stationNameToStation[aName]!
            } else {
                return nil
            }
        } else {
            fatalError("arrivalButton's title is missing!")
        }

        if (whenButton.selectedSegmentIndex == UISegmentedControlNoSegment) {
            return nil
        } else {
            if let name = whenButton.titleForSegmentAtIndex(whenButton.selectedSegmentIndex) {
                category = name
            } else {
                fatalError("whenButton's title is missing!")
            }
        }

        if (category == "Now") {
            isNow = true

            let today = NSDate()
            let f = NSDateFormatter()
            f.dateFormat = "e"
            let weekDay = f.stringFromDate(today).toInt()!

            switch (weekDay) {
            case 1:
                category = "Sunday"
            case 2...6:
                category = "Weekday"
            case 7:
                category = "Saturday"
            default:
                fatalError("Invalid weekDay: \(weekDay)")
            }
        }

        return (departureStations, arrivalStations, category, isNow)
    }

    func updateResults() {
        let services = appDelegate.services

        if let (departureStations, arrivalStations, category, isNow) = getInputs() {
            // if inputs are ready
            var trips = [Trip]()

            for service in services {
                if (service.category != category) {
                    continue
                }

                for dStation in departureStations {
                    for aStation in arrivalStations {
                        if let (from, to) = service.findFrom(dStation, to: aStation) {
                            // check if it's a valid stop
                            if (!isNow || from.laterThanNow) {
                                trips.append(Trip(departure: from, arrival: to))
                            }
                        }
                    }
                }
            }

            sort(&trips) { (a: Trip, b: Trip) -> Bool in
                return a.departureStop.departureTime.timeIntervalSinceDate(b.departureStop.departureTime) < 0
            }
            println(trips.map { $0.departureStop.departureTime })

            resultsTableView.trips = trips
            println("reloadData")
            resultsTableView.reloadData()
        }
    }

}

