//
//  ViewController.swift
//  OneMoreAlarm
//
//  Created by  William on 2/17/19.
//  Copyright © 2019 Vasiliy Lada. All rights reserved.
//

import UIKit

@IBDesignable class ViewController: UIViewController {

    @IBOutlet weak var clock: Clock!
    @IBOutlet weak var dayPick: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        clock.displayRealTime = true
        clock.startClock()
    }

}


