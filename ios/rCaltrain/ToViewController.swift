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

    override func selectionIdentifier() -> String {
        return "selectToLocation"
    }

    override func selectionCallback(controller: MainViewController, selectionText: String) {
        controller.arrivalButton.setTitle(selectionText, forState: .Normal)
    }

}
