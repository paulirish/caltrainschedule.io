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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier {
            switch (id) {
            case "selectFromLocation":
                if let row = self.tableView.indexPathForSelectedRow()?.row {
                    let name: String = StationViewController.stations[row]
                    let destViewController = segue.destinationViewController as MainViewController
                    let button = destViewController.departureButton
                    button.setTitle(name, forState: UIControlState.Normal)
                    println("prepared:selectFromLocation")
                } else {
                    fatalError("unexpected: no row is selected")
                }
            default:
                println(segue.identifier)
                return
            }
        }
    }

}
