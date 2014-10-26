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

    func getInputs() -> ([Station], [Station], String)? {
        let stationNameToStation = appDelegate.stationNameToStation
        var departureStations: [Station]
        var arrivalStations: [Station]
        var whenName: String

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
                whenName = name
            } else {
                fatalError("whenButton's title is missing!")
            }
        }

        return (departureStations, arrivalStations, whenName)
    }

    func updateResults() {
        let services = appDelegate.services

        if let (departureStations, arrivalStations, whenName) = getInputs() {
            // if inputs are ready
            var trips = [Trip]()

            for service in services {
                if (service.category != whenName) {
                    continue
                }

                for dStation in departureStations {
                    for aStation in arrivalStations {
                        if let (from, to) = service.findFrom(dStation, to: aStation) {
                            trips.append(Trip(departure: from, arrival: to))
                        }
                    }
                }
            }

            println(trips.map { $0.departureStop.departureTime })
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

