//
//  StationViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class StationViewController: UITableViewController {
    
    class var stations: [String] {
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.stationsNames
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
        var station = StationViewController.stations[indexPath.row]
        cell.textLabel.text = station

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        TODO
    }
    
}