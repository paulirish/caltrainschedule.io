//
//  LocationViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class LocationViewController: UITableViewController {
    
    var locations: [Location] = [];
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locations.count
    }
    
    func reusableCellName() -> String {
        return "locationCell"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let possibleCell = tableView.dequeueReusableCellWithIdentifier(self.reusableCellName()) as UITableViewCell?
        assert(possibleCell != nil, "reusableCell is missing!")

        let cell = possibleCell!
        var location = self.locations[indexPath.row]
        cell.textLabel.text = location.name
        cell.detailTextLabel?.text = String(location.id)

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locations.append(Location(name: "San Francisco", id: 1))
        self.locations.append(Location(name: "San Jose", id: 2))
        self.locations.append(Location(name: "Sunnyvale", id: 3))
        self.locations.append(Location(name: "Moutain View", id: 4))
        self.locations.append(Location(name: "South San Francisco", id: 5))
    }
    
}