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
    @IBOutlet weak var calendarView2: AYCalendarBarView!
    
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
        self.calendarView.setDateSelectionStyle(.Both)
        self.calendarView.setSelectedTextColor(UIColor.redColor(), enabledDatesColor: UIColor.blackColor(), disabledDatesColor: UIColor.lightGrayColor())
        
        self.calendarView2.settings.noOfVisibleDatesOnScreen = 5
        self.calendarView2.setDateSelectionStyle(.BottomNotch)
        self.calendarView2.setCurrentDate(NSDate(), withMinusNumberOfDays: 1, andPlusDays: 0)
        self.calendarView2.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.calendarView2.layer.borderWidth = 1.0
    }

}

