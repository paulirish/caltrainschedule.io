//
//  ToViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/2/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class ToViewController: LocationViewController {
    
    override func reusableCellName() -> String {
        return "toCell"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier) {
        case "selectToLocation":
            if let row = self.tableView.indexPathForSelectedRow()?.row {
                let name: String = self.locations[row].name
                let destViewController = segue.destinationViewController as MainViewController
                //destViewController.placeholders[1] = name
            } else {
                assert(false, "unexpected: no row is selected")
            }
        default:
            return
        }
    }

}
