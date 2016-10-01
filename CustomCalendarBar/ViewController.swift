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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.calendarView.setCurrentDate(Date(), withMinusNumberOfDays: 10, andPlusDays: 10)
        self.calendarView.setDateSelectionStyle(.both)
        self.calendarView.setSelectedTextColor(UIColor.red, enabledDatesColor: UIColor.black, disabledDatesColor: UIColor.lightGray)
        
        self.calendarView2.settings.noOfVisibleDatesOnScreen = 5
        self.calendarView2.setDateSelectionStyle(.bottomNotch)
        self.calendarView2.setCurrentDate(Date(), withMinusNumberOfDays: 1, andPlusDays: 1)
        self.calendarView2.layer.borderColor = UIColor.lightGray.cgColor
        self.calendarView2.layer.borderWidth = 1.0
    }

}

