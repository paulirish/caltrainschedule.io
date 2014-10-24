//
//  MainViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 9/30/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    required init(coder aDecoder: NSCoder) {
        self.departurePlaceholder = "Departure"
        self.arrivalPlaceholder = "Arrival"
        super.init(coder: aDecoder)
    }

    @IBOutlet var departureButton: UIButton!
    @IBOutlet var arrivalButton: UIButton!
    @IBOutlet var whenButton: UISegmentedControl!
    @IBOutlet var reverseButton: UIButton!
    @IBOutlet var resultsTableView: ResultTableView!

    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        if let id = segue.identifier {
            println("unwind:" + id + "!")
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
    }

    @IBAction func whenChanged(sender: UISegmentedControl) {
        var selectedWhen = sender.titleForSegmentAtIndex(sender.selectedSegmentIndex)
        println("whenChanged:\(selectedWhen)")
        updateResults()
    }

    var departurePlaceholder: String
    var arrivalPlaceholder: String

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

        super.viewDidLoad()
    }

    func updateResults() {
        // TODO
        resultsTableView.results = [
            Result(departureTime: NSDate(timeIntervalSinceNow: 0), arrivalTime: NSDate(timeIntervalSinceNow: 10))
        ]
        println("resloadData")
        resultsTableView.reloadData()
    }


}

