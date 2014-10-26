//
//  ResultTableViewCell.swift
//  rCaltrain
//
//  Created by Wanzhang Sheng on 10/23/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet var departureLabel: UILabel!
    @IBOutlet var arrivalLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!

    func updateData(trip: Trip) {
        departureLabel.text = trip.departureTime
        arrivalLabel.text = trip.arrivalTime
        durationLabel.text = "\(trip.duration)min"
    }

}
