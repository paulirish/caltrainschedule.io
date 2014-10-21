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
        if let id = segue.identifier {
            switch (id) {
            case "selectToLocation":
                if let row = self.tableView.indexPathForSelectedRow()?.row {
                    let name: String = LocationViewController.locations[row].name
                    let destViewController = segue.destinationViewController as MainViewController
                    let button = destViewController.arrivalButton
                    button.setTitle(name, forState: UIControlState.Normal)
                    println("prepared:selectToLocation")
                } else {
                    assert(false, "unexpected: no row is selected")
                }
            default:
                return
            }
        }
    }

}
