//
//  FromViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/1/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class FromViewController: LocationViewController {

    override func reusableCellName() -> String {
        return "fromCell"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println(segue.identifier)

        switch (segue.identifier) {
        case "selectFromLocation":
            if let row = self.tableView.indexPathForSelectedRow()?.row {
                let name: String = self.locations[row].name
                let destViewController = segue.destinationViewController as MainViewController
                println("changeFrom")
                //destViewController.placeholders[0] = name
            } else {
                assert(false, "unexpected: no row is selected")
            }
        default:
            println(segue.identifier)
            return
        }
    }

}
