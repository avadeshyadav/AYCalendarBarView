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
    var selectedBgColor: UIColor?
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
        selectedTextColor = UIColor.whiteColor()
        enabledTextColor = UIColor.darkGrayColor()
        disabledtextColor = UIColor.lightGrayColor()
        selectedBgColor = UIColor(red: 22/255, green: 176/255, blue: 255/255, alpha: 1.0)
        currentDate = NSDate()
        minusDayes = 5;
        plusDays = 5;
        noOfVisibleDatesOnScreen = 7;
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
        loadScrollViewWithDates(self.allDates!)
    }
    
    func setSelectedTextColor(selectedColor: UIColor, enabledDatesColor enabledColor: UIColor, disabledDatesColor disabledColor: UIColor) {
        settings.selectedTextColor = selectedColor
        settings.enabledTextColor = enabledColor
        settings.disabledtextColor = disabledColor
    }
    
    func currentSelectedPageNumber() -> Int {
        return currentSelectedIndex!
    }
    
    func currentSelectedDate() -> NSDate {
        return settings.currentDate!
    }
    
    //MARK: Private Methods
    func doInitialConfigurations() {
        calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        calendar?.locale = NSLocale.autoupdatingCurrentLocale()
        
        dateFormatter = NSDateFormatter()
        dateFormatter?.locale = NSLocale.autoupdatingCurrentLocale()
        dateFormatter?.dateFormat = "MMM dd EEE";
        
        scrollView = UIScrollView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        self.addSubview(scrollView!)
        scrollView?.delegate = self
    }
    
    func didTappedOnDateLabel(recognizer: UIGestureRecognizer) {
        
        let newPage = recognizer.view!.tag - dateLabelTagOffset
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
                label.tag = dateLabelTagOffset + index - settings.noOfVisibleDatesOnScreen! / 2
                label.userInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: "didTappedOnDateLabel:")
                label.addGestureRecognizer(tapGesture)
            }
            else {
                label.textColor = settings.disabledtextColor
            }
            
            scrollView?.addSubview(label)
            
            if (customDate?.date?.compare(settings.currentDate!) == .OrderedSame) {
                self.currentSelectedIndex = index - settings.noOfVisibleDatesOnScreen! / 2
            }
        }
        
        scrollView?.contentSize = CGSizeMake(CGFloat(Int(width) * allCustomDates.count), scrollView!.frame.size.height)
        scrollView?.contentOffset = CGPointMake(CGFloat(currentSelectedIndex! * Int(width)), 0)
        makeSelectionHighlighted(true, forDateIndex: currentSelectedIndex!)
    }
    
    func makeSelectionHighlighted(highlighted: Bool, forDateIndex index: Int) {
        
        let label = scrollView?.viewWithTag(dateLabelTagOffset + index) as? UILabel
        
        if highlighted == true {
            label?.textColor = settings.selectedTextColor
            label?.backgroundColor = settings.selectedBgColor
        }
        else {
            label?.textColor = settings.enabledTextColor
            label?.backgroundColor = UIColor.clearColor()
        }
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
        
      
        // To add current date
        let customDate = AYCustomDate()
        customDate.isEnabled = true
        customDate.date = settings.currentDate
        let dateString = dateFormatter?.stringFromDate(customDate.date!)
        
        if dateString != nil {
            customDate.dateString = getAttributesStringFromDateString(dateString!)
        }
        
        customDates.append(customDate)
        
        
        if forwardDates.count != 0 {
            
            customDates.appendContentsOf(forwardDates)

            var lastEnabledDate = forwardDates.last!.date
            if lastEnabledDate == nil {
                lastEnabledDate = settings.currentDate
            }
            
            let lastDisabledDates = getDatesFromDate(lastEnabledDate!, withOffset: disabledMaxDatesLimit, isForward: true, isEnabled: false)
            
            if lastDisabledDates.count != 0 {
                customDates.appendContentsOf(lastDisabledDates)
            }
        }
        
        return customDates;
    }
    
    func getDatesFromDate(date: NSDate, withOffset offset: Int, isForward: Bool, isEnabled: Bool) -> Array<AYCustomDate> {
        
        var cutomDates = Array<AYCustomDate>()
        
        for (var index = 1; index <= offset; index++) {
            
            let customDate = AYCustomDate()
            
            let componentsToAdd = NSDateComponents()
            componentsToAdd.day = isForward ? index : -(offset - (index - 1))
            
            customDate.isEnabled = isEnabled
            customDate.date = calendar?.dateByAddingComponents(componentsToAdd, toDate: date, options: .WrapComponents)
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
