//
//  FromViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/1/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class FromViewController: StationViewController {

    override func reusableCellName() -> String {
        return "fromCell"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let id = segue.identifier {
            switch (id) {
            case "selectFromLocation":
                let destViewController = segue.destinationViewController as MainViewController
                var name: String

                if let row = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()?.row {
                    name = self.filteredStations[row]
                } else if let row = self.tableView.indexPathForSelectedRow()?.row {
                    name = StationViewController.stations[row]
                } else {
                    fatalError("unexpected: no row is selected")
                }

                let button = destViewController.departureButton
                button.setTitle(name, forState: UIControlState.Normal)
                println("prepared:selectFromLocation")
            default:
                println(segue.identifier)
                return
            }
        }
    }

}
