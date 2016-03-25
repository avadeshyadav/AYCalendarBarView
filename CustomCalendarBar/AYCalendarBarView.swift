//
//  AYCalendarBarView.swift
//  CustomCalendarBar
//
//  Created by Avadesh Kumar on 22/03/16.
//  Copyright © 2016 ibibo Group. All rights reserved.
//

import UIKit

protocol AYCalendarBarViewDelegate {
    func didSelectedNewDate(date: NSDate, withIndex index: Int)
}

class AYCustomDate {
    var date: NSDate?
    var dateString: NSAttributedString?
    var isEnabled: Bool? = false
}

class AYCalendarSettings {
    
    var selectedTextColor: UIColor?
    var enabledTextColor: UIColor?
    var disabledtextColor: UIColor?
    var currentDate: NSDate?
    var minusDayes: Int?
    var plusDays: Int?
    var noOfVisibleDatesOnScreen: Int?
    var smallFont: UIFont?
    var bigFont: UIFont?
    
    init () {
        self.defaultSettings()
    }
    
    func defaultSettings() {
        selectedTextColor = UIColor.blackColor()
        enabledTextColor = UIColor.darkGrayColor()
        disabledtextColor = UIColor.lightGrayColor()
        currentDate = NSDate()
        minusDayes = 5;
        plusDays = 5;
        noOfVisibleDatesOnScreen = 5;
        smallFont = UIFont.systemFontOfSize(10.0)
        bigFont = UIFont.boldSystemFontOfSize(12.0)
    }
}

class AYCalendarBarView: UIView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView?
    
    var allDates: Array<AYCustomDate>?
    var settings = AYCalendarSettings()
    var calendar: NSCalendar?
    var dateFormatter: NSDateFormatter?
    let dateLabelTagOffset = 1000
    var currentSelectedIndex: Int?
    var delegate: AYCalendarBarViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doInitialConfigurations()
    }
    
    //MARK: Public Methods
    func setCurrentDate(currentDate: NSDate, withMinusNumberOfDays minusDays: Int, andPlusDays plusDays: Int) {
        
        settings.currentDate = currentDate
        settings.minusDayes = minusDays
        settings.plusDays = plusDays
        
        self.allDates = self.getAllVisibleCustomDates()
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
        calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.locale = NSLocale.autoupdatingCurrentLocale()
        
        dateFormatter = NSDateFormatter()
        dateFormatter?.locale = NSLocale.autoupdatingCurrentLocale()
        dateFormatter?.dateFormat = "MMM dd EEE";
    }
    
    func didTappedOnDateLabel(recognizer: UIGestureRecognizer) {
        
        let newPage = recognizer.view!.tag// - settings.noOfVisibleDatesOnScreen! / 2
        handleNewDateIndexWithNumber(newPage)
    }
    
    
    func handleNewDateSelectionFromScrollViewContentOffset(offset: CGPoint) {
        let width = self.frame.size.width / CGFloat(settings.noOfVisibleDatesOnScreen!)
        let newIndex = Int(offset.x + width / 2) / Int(width)
        self.handleNewDateIndexWithNumber(newIndex)
    }
    
    func handleNewDateIndexWithNumber(newIndex: Int) {
        
        if (newIndex == currentSelectedIndex) {
            return
        }
        
        makeSelectionHighlighted(false, forDateIndex: currentSelectedIndex!)
        makeSelectionHighlighted(true, forDateIndex: newIndex)
        self.currentSelectedIndex = newIndex
        
        callDelegateWithSelectedIndex()
        moveScrollViewToDateIndex(newIndex, animated: true)
        
    }
    
    func moveScrollViewToDateIndex(index: Int, animated: Bool) {
        
        let width = self.frame.size.width / CGFloat(settings.noOfVisibleDatesOnScreen!)
        scrollView?.setContentOffset(CGPointMake(CGFloat(Int(width) * index), 0), animated: animated)
    }
    
    func callDelegateWithSelectedIndex() {
        let customDate = self.allDates![currentSelectedIndex!]
        delegate?.didSelectedNewDate(customDate.date!, withIndex: currentSelectedIndex!)
    }
    
    func loadScrollViewWithDates(customDates: Array<AYCustomDate>) {
        
        for view in scrollView!.subviews {
            view.removeFromSuperview()
        }
        
        let allCustomDates: NSArray = customDates
        let width = self.frame.size.width / CGFloat(settings.noOfVisibleDatesOnScreen!)
        
        for date in allCustomDates {
            
            let customDate = date as? AYCustomDate
            let index = allCustomDates.indexOfObject(date)
            
            let label = UILabel()
            label.frame = CGRectMake(CGFloat(index * Int(width)), 0, width, scrollView!.frame.size.height)
            label.attributedText = customDate!.dateString
            label.textAlignment = .Center
            label.numberOfLines = 3
            
            if customDate?.isEnabled == true {
                label.tag = index
                let tapGesture = UITapGestureRecognizer(target: self, action: "didTappedOnDateLabel:")
                label.addGestureRecognizer(tapGesture)
            }
            else {
                label.textColor = settings.disabledtextColor
            }
            
            scrollView?.addSubview(label)
            scrollView?.contentSize = CGSizeMake(CGFloat(Int(width) * allCustomDates.count), scrollView!.frame.size.height)
            self.currentSelectedIndex = index
            scrollView?.contentOffset = CGPointMake(CGFloat(index * Int(width)), 0)
            makeSelectionHighlighted(true, forDateIndex: index)
        }
    }
    
    func makeSelectionHighlighted(highlighted: Bool, forDateIndex index: Int) {
        
        let label = scrollView?.viewWithTag(dateLabelTagOffset + index) as? UILabel
        
        if highlighted == true {
            label?.textColor = settings.selectedTextColor
            label?.backgroundColor = UIColor.clearColor()
        }
        else {
            label?.textColor = settings.enabledTextColor
            label?.backgroundColor = UIColor.clearColor()        }
    }
    
    func getAttributesStringFromDateString(dateString: String) -> NSAttributedString {
        
        let components: NSArray = dateString.componentsSeparatedByString(" ")
        if components.count != 3 {
            return NSAttributedString()
        }
        
        let attributedString = NSMutableAttributedString(string: components.firstObject as! String, attributes: [NSFontAttributeName: settings.smallFont!])
        
        attributedString.appendAttributedString(NSAttributedString(string: "\n\(components[1])" , attributes: [NSFontAttributeName: settings.bigFont!]))
        
        attributedString.appendAttributedString(NSAttributedString(string: "\n\(components.lastObject!)" , attributes: [NSFontAttributeName: settings.smallFont!]))
        
        return attributedString
    }
    
    func getAllVisibleCustomDates() -> Array<AYCustomDate> {
        
        var customDates = Array<AYCustomDate>()
        let disabledMaxDatesLimit = settings.noOfVisibleDatesOnScreen! / 2;
        
        let forwardDates = getDatesFromDate(settings.currentDate!, withOffset: settings.plusDays!, isForward: true, isEnabled: true)
        let backwardDates = getDatesFromDate(settings.currentDate!, withOffset: settings.minusDayes!, isForward: false, isEnabled: true)
        
        if backwardDates.count != 0 {
            
            var firstEnabledDate = backwardDates.first!.date
            if firstEnabledDate == nil {
                firstEnabledDate = settings.currentDate
            }
            
            let startingDisabledDates = getDatesFromDate(firstEnabledDate!, withOffset: disabledMaxDatesLimit, isForward: false, isEnabled: false)
            
            if startingDisabledDates.count != 0 {
                customDates.appendContentsOf(startingDisabledDates)
            }
            
            customDates.appendContentsOf(backwardDates)
        }
        
        if forwardDates.count != 0 {
            
            var lastEnabledDate = forwardDates.last!.date
            if lastEnabledDate == nil {
                lastEnabledDate = settings.currentDate
            }
            
            let lastDisabledDates = getDatesFromDate(lastEnabledDate!, withOffset: disabledMaxDatesLimit, isForward: true, isEnabled: false)
            
            if lastDisabledDates.count != 0 {
                customDates.appendContentsOf(lastDisabledDates)
            }
            
            customDates.appendContentsOf(forwardDates)
        }
        
        return customDates;
    }
    
    func getDatesFromDate(date: NSDate, withOffset offset: Int, isForward: Bool, isEnabled: Bool) -> Array<AYCustomDate> {
        
        var cutomDates = Array<AYCustomDate>()
        
        for (var index = 1; index <= offset; index++) {
            
            let customDate = AYCustomDate()
            
            let componentsToAdd = NSDateComponents()
            componentsToAdd.day = isForward ? index : -index
            
            customDate.isEnabled = isEnabled
            customDate.date = calendar?.dateByAddingComponents(componentsToAdd, toDate: settings.currentDate!, options: .WrapComponents)
            let dateString = dateFormatter?.stringFromDate(customDate.date!)
            
            if dateString != nil {
                customDate.dateString = getAttributesStringFromDateString(dateString!)
            }
            
            cutomDates.append(customDate)
        }
        
        return cutomDates
    }
    
    
    //MARK: UIScrollView Delegate Methods
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        handleNewDateSelectionFromScrollViewContentOffset(scrollView.contentOffset)
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        handleNewDateSelectionFromScrollViewContentOffset(targetContentOffset.memory)
    }
    
}
