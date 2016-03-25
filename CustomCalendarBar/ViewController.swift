//
//  ViewController.swift
//  CustomCalendarBar
//
//  Created by Avadesh Kumar on 20/03/16.
//  Copyright © 2016 ibibo Group. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: AYCalendarBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.calendarView.setCurrentDate(NSDate(), withMinusNumberOfDays: 10, andPlusDays: 10)
    }

}

