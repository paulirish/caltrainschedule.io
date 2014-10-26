//
//  StationViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class StationViewController: UITableViewController {
    
    class var stations: [Station] {
        get {
            return [
                Station(name: "San Francisco", id: 1),
                Station(name: "San Jose", id: 2),
                Station(name: "Sunnyvale", id: 3),
                Station(name: "Moutain View", id: 4),
                Station(name: "So. San Francisco", id: 5)
            ]
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StationViewController.stations.count
    }
    
    func reusableCellName() -> String {
        fatalError("reusable cell name need to be specified by subclass!")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let possibleCell = tableView.dequeueReusableCellWithIdentifier(self.reusableCellName()) as UITableViewCell?
        assert(possibleCell != nil, "reusableCell is missing!")

        let cell = possibleCell!
        var Station = StationViewController.stations[indexPath.row]
        cell.textLabel.text = Station.name
        cell.detailTextLabel?.text = String(Station.id)

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        TODO
    }
    
}