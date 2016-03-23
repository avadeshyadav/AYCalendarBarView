//
//  AYCalendarBarView.swift
//  CustomCalendarBar
//
//  Created by Avadesh Kumar on 22/03/16.
//  Copyright © 2016 ibibo Group. All rights reserved.
//

import UIKit


class AYCustomDate {
    var date: NSDate?
    var dateString: NSAttributedString?
    var isEnabled: Bool? = false
}

class AYCalendarSettings {
    var selectedTextColor: UIColor?
    var enabledTextColor: UIColor?
    var disabledtextColor: UIColor?
}

class AYCalendarBarView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doInitialConfigurations()
    }
    
    //MARK: Public Methods
    func setCurrentDate(currentDate: NSDate, withMinusNumberOfDays minusDays: Int, andPlusDays plusDays: Int) {
    
    }
    
    func setSelectedTextColor(selectedColor: UIColor, enabledDatesColor enabledColor: UIColor, disabledDatesColor disabledColor: UIColor) {
    
    }
    
    func currentSelectedPageNumber() -> Int {
        return 1;
    }
    
    func currentSelectedDate() -> NSDate {
        return NSDate()
    }
    
    
    //MARK: Private Methods
    func doInitialConfigurations() {
    
    }
}
