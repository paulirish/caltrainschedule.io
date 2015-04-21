//
//  ToViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import UIKit

class ToViewController: StationViewController {
    
    override func reusableCellName() -> String {
        return "toCell"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            switch (id) {
            case "selectToLocation":
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
                    fatalError("unexpected: no row is selected in ToTableView")
                }

                self.resultSearchController.active = false

                destViewController.arrivalButton.setTitle(name, forState: .Normal)
            default:
                println(segue.identifier)
                return
            }
        }
    }

}
