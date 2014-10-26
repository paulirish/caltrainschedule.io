//
//  ResultTableView.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/22/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class ResultTableView:UITableView, UITableViewDataSource {

    var trips:[Trip] = []

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let resultCell = tableView.dequeueReusableCellWithIdentifier("resultCell") as? ResultTableViewCell {
            resultCell.updateData(trips[indexPath.row])
            return resultCell
        } else {
            fatalError("No resultCell in ResultTableView!")
        }
    }
}
