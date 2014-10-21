//
//  LocationViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class LocationViewController: UITableViewController {
    
    class var locations: [Location] {
        get {
            return [
                Location(name: "San Francisco", id: 1),
                Location(name: "San Jose", id: 2),
                Location(name: "Sunnyvale", id: 3),
                Location(name: "Moutain View", id: 4),
                Location(name: "So. San Francisco", id: 5)
            ]
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LocationViewController.locations.count
    }
    
    func reusableCellName() -> String {
        fatalError("reusable cell name need to be specified by subclass!")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let possibleCell = tableView.dequeueReusableCellWithIdentifier(self.reusableCellName()) as UITableViewCell?
        assert(possibleCell != nil, "reusableCell is missing!")

        let cell = possibleCell!
        var location = LocationViewController.locations[indexPath.row]
        cell.textLabel.text = location.name
        cell.detailTextLabel?.text = String(location.id)

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        TODO
    }
    
}