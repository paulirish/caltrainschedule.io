//
//  FromViewController.swift
//  rCaltrain
//
//  Created by Ranmocy on 10/1/14.
//  Copyright (c) 2014-2015 Ranmocy. All rights reserved.
//

import UIKit

class FromViewController: StationViewController {

    override func reusableCellName() -> String {
        return "fromCell"
    }

    override func selectionIdentifier() -> String {
        return "selectFromLocation"
    }

    override func selectionCallback(controller: MainViewController, selectionText: String) {
        controller.departureButton.setTitle(selectionText, forState: .Normal)
    }

}
