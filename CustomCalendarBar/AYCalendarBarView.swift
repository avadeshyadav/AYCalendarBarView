//
//  AYCalendarBarView.swift
//  CustomCalendarBar
//
//  Created by Avadesh Kumar on 22/03/16.
//  Copyright © 2016 ibibo Group. All rights reserved.
//

import UIKit

protocol AYCalendarBarViewDelegate {
    func didSelectedNewDate(_ date: Date, withIndex index: Int)
}

enum DateSelectionStyle: Int {
    case seletedBackground,
    bottomNotch,
    both,
    none
}

class AYCustomDate {
    var date: Date?
    var dateString: NSAttributedString?
    var isEnabled: Bool? = false
}

class AYCalendarSettings {
    
    var selectedTextColor: UIColor?
    var enabledTextColor: UIColor?
    var disabledtextColor: UIColor?
    var selectedBgColor: UIColor?
    var currentDate: Date?
    var minusDayes: Int?
    var plusDays: Int?
    var noOfVisibleDatesOnScreen: Int?
    var smallFont: UIFont?
    var bigFont: UIFont?
    var selectionStyle: DateSelectionStyle?
    
    init () {
        self.defaultSettings()
    }
    
    func defaultSettings() {
        selectedTextColor = UIColor.red
        enabledTextColor = UIColor.darkGray
        disabledtextColor = UIColor.lightGray
        selectedBgColor = UIColor.clear
        currentDate = Date()
        minusDayes = 5;
        plusDays = 5;
        noOfVisibleDatesOnScreen = 7;
        smallFont = UIFont.systemFont(ofSize: 10.0)
        bigFont = UIFont.boldSystemFont(ofSize: 12.0)
        selectionStyle = .both
    }
}

class AYCalendarBarView: UIView, UIScrollViewDelegate {
    
    var scrollView: UIScrollView?
    
    var allDates: Array<AYCustomDate>?
    var settings = AYCalendarSettings()
    var calendar: Calendar?
    var dateFormatter: DateFormatter?
    var currentSelectedIndex: Int?
    var delegate: AYCalendarBarViewDelegate?
    
    //Local constants decleration:
    let dateLabelTagOffset = 1000
    let bottomNotchViewTag = 10010
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doInitialConfigurations()
    }
    
    //MARK: Public Methods
    func setCurrentDate(_ currentDate: Date, withMinusNumberOfDays minusDays: Int, andPlusDays plusDays: Int) {
        
        settings.currentDate = currentDate
        settings.minusDayes = minusDays
        settings.plusDays = plusDays
        
        self.allDates = self.getAllVisibleCustomDates()
        loadScrollViewWithDates(self.allDates!)
    }
    
    func setSelectedTextColor(_ selectedColor: UIColor, enabledDatesColor enabledColor: UIColor, disabledDatesColor disabledColor: UIColor) {
        settings.selectedTextColor = selectedColor
        settings.enabledTextColor = enabledColor
        settings.disabledtextColor = disabledColor
        
        if (self.allDates != nil) {
            loadScrollViewWithDates(self.allDates!)
        }
    }
    
    func setDateSelectionStyle(_ style: DateSelectionStyle) {
    
        //Remove previous selection style first, if this method get called more than once.
        let notchView: UIView? = self.viewWithTag(bottomNotchViewTag)
        notchView?.removeFromSuperview()
        settings.selectedBgColor = UIColor.clear
        
        switch style {
        case .both:
            addBottomNotchView()
            addSelectedBackGroundColor()
        
        case .seletedBackground:
            addSelectedBackGroundColor()

        case .bottomNotch:
            addBottomNotchView()

        case .none:
            break;
            
        }
    }
    
    func currentSelectedPageNumber() -> Int {
        return currentSelectedIndex!
    }
    
    func currentSelectedDate() -> Date {
        return settings.currentDate!
    }
    
    //MARK: Private Methods
    func doInitialConfigurations() {
        calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar?.locale = Locale.autoupdatingCurrent
        
        dateFormatter = DateFormatter()
        dateFormatter?.locale = Locale.autoupdatingCurrent
        dateFormatter?.dateFormat = "MMM dd EEE";
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(scrollView!)
        scrollView?.delegate = self
    }
    
    func didTappedOnDateLabel(_ recognizer: UIGestureRecognizer) {
        
        let newPage = recognizer.view!.tag - dateLabelTagOffset
        handleNewDateIndexWithNumber(newPage)
    }
    
    func handleNewDateSelectionFromScrollViewContentOffset(_ offset: CGPoint) {
        let width = self.frame.size.width / CGFloat(settings.noOfVisibleDatesOnScreen!)
        let newIndex = Int(offset.x + width / 2) / Int(width)
        self.handleNewDateIndexWithNumber(newIndex)
    }
    
    func handleNewDateIndexWithNumber(_ newIndex: Int) {
        
        if (newIndex == currentSelectedIndex) {
            return
        }
        
        makeSelectionHighlighted(false, forDateIndex: currentSelectedIndex!)
        makeSelectionHighlighted(true, forDateIndex: newIndex)
        self.currentSelectedIndex = newIndex
        
        callDelegateWithSelectedIndex()
        moveScrollViewToDateIndex(newIndex, animated: true)
        
    }
    
    func moveScrollViewToDateIndex(_ index: Int, animated: Bool) {
        
        let width = self.frame.size.width / CGFloat(settings.noOfVisibleDatesOnScreen!)
        scrollView?.setContentOffset(CGPoint(x: CGFloat(Int(width) * index), y: 0), animated: animated)
    }
    
    func callDelegateWithSelectedIndex() {
        let customDate = self.allDates![currentSelectedIndex!]
        delegate?.didSelectedNewDate(customDate.date!, withIndex: currentSelectedIndex!)
    }
    
    func addBottomNotchView() {
        
        let view = UIView(frame: CGRect(x: 0, y: self.scrollView!.frame.size.height - 4, width: self.scrollView!.frame.size.width, height: 4))
        view.backgroundColor = UIColor(red: 22/255, green: 176/255, blue: 255/255, alpha: 1.0)
        view.tag = bottomNotchViewTag
        self.addSubview(view)
        
        //Add bottom notch
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = view.backgroundColor?.cgColor
        let sizeOfNotch: CGFloat = 10
        
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: view.center.x - sizeOfNotch/2, y: 0))
        path.addLine(to: CGPoint(x: view.center.x, y: 0 - sizeOfNotch/2))
        path.addLine(to: CGPoint(x: view.center.x + sizeOfNotch/2, y: 0))

        
//        CGPathMoveToPoint(path, nil, view.center.x - sizeOfNotch/2, 0);
//        CGPathAddLineToPoint(path, nil, view.center.x,  0 - sizeOfNotch/2);
//        CGPathAddLineToPoint(path, nil, view.center.x + sizeOfNotch/2,  0);
        shapeLayer.path = path;
        
        view.layer.addSublayer(shapeLayer)
        
    }
    
    func addSelectedBackGroundColor() {
        settings.selectedBgColor = UIColor.lightGray
    }
    
    func loadScrollViewWithDates(_ customDates: Array<AYCustomDate>) {
        
        for view in scrollView!.subviews {
            view.removeFromSuperview()
        }
        
        let allCustomDates: NSArray = customDates as NSArray
        let width = self.frame.size.width / CGFloat(settings.noOfVisibleDatesOnScreen!)
        
        for date in allCustomDates {
            
            let customDate = date as? AYCustomDate
            let index = allCustomDates.index(of: date)
            
            let label = UILabel()
            label.frame = CGRect(x: CGFloat(index * Int(width)), y: 0, width: width, height: scrollView!.frame.size.height)
            label.attributedText = customDate!.dateString
            label.textAlignment = .center
            label.numberOfLines = 3
            
            if customDate?.isEnabled == true {
                label.tag = dateLabelTagOffset + index - settings.noOfVisibleDatesOnScreen! / 2
                label.isUserInteractionEnabled = true
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AYCalendarBarView.didTappedOnDateLabel(_:)))
                label.addGestureRecognizer(tapGesture)
            }
            else {
                label.textColor = settings.disabledtextColor
            }
            
            scrollView?.addSubview(label)
            
            if (customDate?.date?.compare(settings.currentDate!) == .orderedSame) {
                self.currentSelectedIndex = index - settings.noOfVisibleDatesOnScreen! / 2
            }
        }
        
        scrollView?.contentSize = CGSize(width: CGFloat(Int(width) * allCustomDates.count), height: scrollView!.frame.size.height)
        scrollView?.contentOffset = CGPoint(x: CGFloat(currentSelectedIndex! * Int(width)), y: 0)
        makeSelectionHighlighted(true, forDateIndex: currentSelectedIndex!)
    }
    
    func makeSelectionHighlighted(_ highlighted: Bool, forDateIndex index: Int) {
        
        let label = scrollView?.viewWithTag(dateLabelTagOffset + index) as? UILabel
        
        if highlighted == true {
            label?.textColor = settings.selectedTextColor
            label?.backgroundColor = settings.selectedBgColor
        }
        else {
            label?.textColor = settings.enabledTextColor
            label?.backgroundColor = UIColor.clear
        }
    }
    
    func getAttributesStringFromDateString(_ dateString: String) -> NSAttributedString {
        
        let components: Array<String> = dateString.components(separatedBy: " ")
        if components.count != 3 {
            return NSAttributedString()
        }
        
        let attributedString = NSMutableAttributedString(string: components.first!, attributes: [NSFontAttributeName: settings.smallFont!])
        
        attributedString.append(NSAttributedString(string: "\n\(components[1])" , attributes: [NSFontAttributeName: settings.bigFont!]))
        
        attributedString.append(NSAttributedString(string: "\n\(components.last!)" , attributes: [NSFontAttributeName: settings.smallFont!]))
        
        return attributedString
    }
    
    func getAllVisibleCustomDates() -> Array<AYCustomDate> {
        
        var customDates = Array<AYCustomDate>()
        let disabledMaxDatesLimit = settings.noOfVisibleDatesOnScreen! / 2;
        
        let forwardDates = getDatesFromDate(settings.currentDate!, withOffset: settings.plusDays!, isForward: true, isEnabled: true)
        let backwardDates = getDatesFromDate(settings.currentDate!, withOffset: settings.minusDayes!, isForward: false, isEnabled: true)
        
        var firstEnabledDate = backwardDates.first?.date
        if firstEnabledDate == nil {
            firstEnabledDate = settings.currentDate
        }
        
        let startingDisabledDates = getDatesFromDate(firstEnabledDate!, withOffset: disabledMaxDatesLimit, isForward: false, isEnabled: false)
        
        if startingDisabledDates.count != 0 {
            customDates.append(contentsOf: startingDisabledDates)
        }
        
        if backwardDates.count != 0 {
            customDates.append(contentsOf: backwardDates)
        }
        
      
        // To add current date
        let customDate = AYCustomDate()
        customDate.isEnabled = true
        customDate.date = settings.currentDate
        let dateString = dateFormatter?.string(from: customDate.date!)
        
        if dateString != nil {
            customDate.dateString = getAttributesStringFromDateString(dateString!)
        }
        
        customDates.append(customDate)
        
        if forwardDates.count != 0 {
            customDates.append(contentsOf: forwardDates)
        }
        
        var lastEnabledDate = forwardDates.last?.date
        if lastEnabledDate == nil {
            lastEnabledDate = settings.currentDate
        }
        
        let lastDisabledDates = getDatesFromDate(lastEnabledDate!, withOffset: disabledMaxDatesLimit, isForward: true, isEnabled: false)
        
        if lastDisabledDates.count != 0 {
            customDates.append(contentsOf: lastDisabledDates)
        }
        
        return customDates;
    }
    
    func getDatesFromDate(_ date: Date, withOffset offset: Int, isForward: Bool, isEnabled: Bool) -> Array<AYCustomDate> {
        
        var cutomDates = Array<AYCustomDate>()
        
       // for (var index = 1; index <= offset; index += 1) {
        
        if offset < 1 {
            return cutomDates
        }
        
        for  index in 1...offset {
         
            let customDate = AYCustomDate()
            
            var componentsToAdd = DateComponents()
            componentsToAdd.day = isForward ? index : -(offset - (index - 1))
            
            customDate.isEnabled = isEnabled
            customDate.date = (calendar as NSCalendar?)?.date(byAdding: componentsToAdd, to: date, options: .wrapComponents)
            let dateString = dateFormatter?.string(from: customDate.date!)
            
            if dateString != nil {
                customDate.dateString = getAttributesStringFromDateString(dateString!)
            }
            
            cutomDates.append(customDate)
        }
        
        return cutomDates
    }
    
    
    //MARK: UIScrollView Delegate Methods
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        handleNewDateSelectionFromScrollViewContentOffset(scrollView.contentOffset)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        handleNewDateSelectionFromScrollViewContentOffset(targetContentOffset.pointee)
    }
    
}
