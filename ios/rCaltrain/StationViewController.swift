//
//  StationViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import UIKit

class StationViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    var stationNames = [String]()
    var filteredNames = [String]()

    // search functionality
    @IBOutlet var searchBar: UISearchBar!

    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterStations(searchString)
        return true
    }

    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterStations(self.searchDisplayController!.searchBar.text)
        return true
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return filteredNames.count
        } else {
            return stationNames.count
        }
    }
    
    func reusableCellName() -> String {
        fatalError("reusable cell name need to be specified by subclass!")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = self.tableView.dequeueReusableCellWithIdentifier(self.reusableCellName()) as UITableViewCell? {
            var stations: [String]
            if tableView == self.searchDisplayController!.searchResultsTableView {
                stations = filteredNames
            } else {
                stations = stationNames
            }
            cell.textLabel!.text = stations[indexPath.row]

            return cell
        } else {
            fatalError("reusableCell: (\(self.reusableCellName())) is missing!")
        }
    }

    override func viewDidLoad() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        stationNames = appDelegate.stationNames
    }

    // private helper

    func filterStations(searchText: String) {
        if (searchText == "") {
            filteredNames = stationNames
        } else {
            filteredNames = stationNames.filter() { /searchText/"i" =~ $0 }
        }
    }

}
