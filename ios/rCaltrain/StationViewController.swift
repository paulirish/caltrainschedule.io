//
//  StationViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import UIKit

class StationViewController: UITableViewController, UISearchResultsUpdating {

    var stationNames = [String]()
    var filteredNames = [String]()

    // search functionality
    @IBOutlet var searchBar: UISearchBar!
    var resultSearchController = UISearchController()


    // Table View
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.resultSearchController.active {
            return filteredNames.count
        } else {
            return stationNames.count
        }
    }
    
    func reusableCellName() -> String {
        fatalError("reusable cell name need to be specified by subclass!")
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(self.reusableCellName(), forIndexPath: indexPath) as? UITableViewCell {
            var stations: [String]
            if self.resultSearchController.active {
                stations = filteredNames
            } else {
                stations = stationNames
            }
            cell.textLabel?.text = stations[indexPath.row]

            return cell
        } else {
            fatalError("reusableCell: (\(self.reusableCellName())) is missing!")
        }
    }


    // Search View
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterStations(searchController.searchBar.text)
        self.tableView.reloadData()
    }

    func selectionIdentifier() -> String {
        fatalError("selectionIdentifier should be specified by subclass!")
    }

    func selectionCallback(controller: MainViewController, selectionText: String) {
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            switch (id) {
            case selectionIdentifier():
                let destViewController = segue.destinationViewController as! MainViewController
                var name: String
                var table: [String]

                if (self.resultSearchController.active) {
                    table = filteredNames
                } else {
                    table = stationNames
                }

                if let row = self.tableView.indexPathForSelectedRow()?.row {
                    name = table[row]
                } else {
                    fatalError("unexpected: no row is selected in \(selectionIdentifier())")
                }

                self.resultSearchController.active = false

                selectionCallback(destViewController, selectionText: name)
            default:
                println(segue.identifier)
                return
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        stationNames = Station.getNames()

        self.resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.hidesNavigationBarDuringPresentation = true
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()

            self.tableView.tableHeaderView = controller.searchBar

            return controller
        })()
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
