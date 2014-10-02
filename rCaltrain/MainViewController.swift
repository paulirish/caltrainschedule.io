//
//  MainViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 9/30/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource {
    let labels = ["From:", "To:", "When:"]
    var placeholders = ["Departure", "Destination", "Service"]

    var results: [String] = []

    @IBOutlet var queryTable: UITableView!

    @IBAction func unwindFromModalViewController(segue: UIStoryboardSegue) {
        println(segue.identifier + "!")
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(self.queryTable) {
            return self.labels.count
        } else {
            fatalError("Invalid View.")
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.isEqual(self.queryTable) {
            let cell = tableView.dequeueReusableCellWithIdentifier("queryCell") as UITableViewCell
            let row = indexPath.row
            cell.textLabel?.text = self.labels[row]
            cell.detailTextLabel?.text = self.placeholders[row]
            return cell
        } else {
            fatalError("Invalid View.")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view.subviews[0] as UITableView
        view.dataSource = self
    }

}

