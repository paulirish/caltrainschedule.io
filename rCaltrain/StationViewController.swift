//
//  StationViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class StationViewController: UITableViewController, UISearchBarDelegate, UISearchDisplayDelegate {

    class var stations: [String] {
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        return appDelegate.stationsNames
    }

    // search functionality
    @IBOutlet var searchBar: UISearchBar!

    var filteredStations = [String]()

    func filterStations(searchText: String) {
        if (searchText == "") {
            filteredStations = StationViewController.stations
        } else {
            filteredStations = StationViewController.stations.filter() {
                $0.rangeOfString(searchText, options: .RegularExpressionSearch) != nil
            }
        }
    }

    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterStations(searchString)
        return true
    }

//    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
//        self.filterStations(self.searchDisplayController!.searchBar.text)
//        return true
//    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredStations.count
        } else {
            return StationViewController.stations.count
        }
    }
    
    func reusableCellName() -> String {
        fatalError("reusable cell name need to be specified by subclass!")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let possibleCell = self.tableView.dequeueReusableCellWithIdentifier(self.reusableCellName()) as UITableViewCell?
        assert(possibleCell != nil, "reusableCell: (\(self.reusableCellName())) is missing!")
        let cell = possibleCell!

        var stationName: String
        if tableView == self.searchDisplayController!.searchResultsTableView {
            stationName = self.filteredStations[indexPath.row]
        } else {
            stationName = StationViewController.stations[indexPath.row]
        }
        cell.textLabel.text = stationName

        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        TODO
    }
    
}