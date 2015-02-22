//
//  MainViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 9/30/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    var departurePlaceholder: String = "Departure"
    var arrivalPlaceholder: String = "Arrival"

    @IBOutlet var departureButton: UIButton!
    @IBOutlet var arrivalButton: UIButton!
    @IBOutlet var whenButton: UISegmentedControl!
    @IBOutlet var reverseButton: UIButton!
    @IBOutlet var resultsTableView: ResultTableView!

    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            updateResults()
        } else {
            fatalError("Unexpected segue without identifier!")
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
        updateResults()
    }

    func savePreference(from: String, to: String, when: Int) {
        let pref = NSUserDefaults.standardUserDefaults()
        pref.setObject(from, forKey: "from")
        pref.setObject(to, forKey: "to")
        pref.setInteger(when, forKey: "when")
        pref.synchronize()
    }

    func loadPreference() {
        let pref = NSUserDefaults.standardUserDefaults()

        if let from = pref.stringForKey("from") {
            departureButton.setTitle(from, forState: .Normal)
        }

        if let to = pref.stringForKey("to") {
            arrivalButton.setTitle(to, forState: .Normal)
        }

        let when = pref.integerForKey("when")
        let length = whenButton.numberOfSegments
        if (0 <= when && when < length) {
            whenButton.selectedSegmentIndex = when
        }
    }

    override func viewDidLoad() {
        // load placeholder
        departureButton.setTitle(departurePlaceholder, forState: .Normal)
        arrivalButton.setTitle(arrivalPlaceholder, forState: .Normal)

        // setups
        resultsTableView.dataSource = resultsTableView
        super.viewDidLoad()

        // init update
        loadPreference()
        updateResults()
    }

    // Get inputs value. If some input is missing, return nil
    // Return: ([departure_stations], [arrival_stations], category, isNow)?
    func getInputs() -> ([Station], [Station], String)? {
        var departureStations: [Station]
        var arrivalStations: [Station]
        var category: String

        // get departure stations
        if let dName = departureButton.currentTitle {
            if let stations = Station.getStations(byName: dName) {
                departureStations = stations
            } else {
                return nil
            }
        } else {
            fatalError("departureButton's title is missing!")
        }

        // get arrival stations
        if let aName = arrivalButton.currentTitle {
            if let stations = Station.getStations(byName: aName) {
                arrivalStations = stations
            } else {
                return nil
            }
        } else {
            fatalError("arrivalButton's title is missing!")
        }

        // get service category
        if (whenButton.selectedSegmentIndex == UISegmentedControlNoSegment) {
            return nil
        } else if let name = whenButton.titleForSegmentAtIndex(whenButton.selectedSegmentIndex) {
            category = name
        } else {
            fatalError("whenButton's title is missing!")
        }

        savePreference(departureButton.currentTitle!, to: arrivalButton.currentTitle!, when: whenButton.selectedSegmentIndex)

        return (departureStations, arrivalStations, category)
    }

    func updateResults() {
        // if inputs are ready update, otherwise ignore it
        if let (departureStations, arrivalStations, category) = getInputs() {
            var results = [Result]()
            var services = Service.getAllServices().filter { s in
                return s.isValidAt(category)
            }

            for service in services {
                for (trip_id, trip) in service.trips {
                    for dStation in departureStations {
                        for aStation in arrivalStations {
                            if let (from, to) = trip.findFrom(dStation, to: aStation) {
                                // check if it's a valid stop
                                if (category != "Now" || from.laterThanNow) {
                                    results.append(Result(departure: from, arrival: to))
                                }
                            }
                        }
                    }
                }
            }

            results.sort { $0.departureTime < $1.departureTime }

            resultsTableView.results = results
            resultsTableView.reloadData()
        }
    }

}

