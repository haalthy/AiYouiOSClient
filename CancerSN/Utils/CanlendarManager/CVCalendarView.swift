//
//  CVCalendarView.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/26/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

typealias WeekView = CVCalendarWeekView
typealias CalendarView = CVCalendarView
typealias MonthView = CVCalendarMonthView
typealias Manager = CVCalendarManager
typealias DayView = CVCalendarDayView
typealias ContentController = CVCalendarContentViewController
typealias Appearance = CVCalendarViewAppearance
typealias Coordinator = CVCalendarDayViewControlCoordinator
typealias Date = CVDate
typealias CalendarMode = CVCalendarViewPresentationMode
typealias Weekday = CVCalendarWeekday
typealias Animator = CVCalendarViewAnimator
typealias Delegate = CVCalendarViewDelegate
typealias AppearanceDelegate = CVCalendarViewAppearanceDelegate
typealias AnimatorDelegate = CVCalendarViewAnimatorDelegate
typealias ContentViewController = CVCalendarContentViewController
typealias MonthContentViewController = CVCalendarMonthContentViewController
typealias WeekContentViewController = CVCalendarWeekContentViewController
typealias MenuViewDelegate = CVCalendarMenuViewDelegate
typealias TouchController = CVCalendarTouchController
typealias SelectionType = CVSelectionType

class CVCalendarView: UIView {
    // MARK: - Public properties
    var manager: Manager!
    var appearance: Appearance!
    var touchController: TouchController!
    var coordinator: Coordinator!
    var animator: Animator!
    var contentController: ContentViewController!
    var calendarMode: CalendarMode!
    
    var (weekViewSize, dayViewSize): (CGSize?, CGSize?)
    
    fileprivate var validated = false
    
    var firstWeekday: Weekday {
        get {
            if let delegate = delegate {
                return delegate.firstWeekday()
            } else {
                return .sunday
            }
        }
    }
    
    var shouldShowWeekdaysOut: Bool! {
        if let delegate = delegate, let shouldShow = delegate.shouldShowWeekdaysOut?() {
            return shouldShow
        } else {
            return false
        }
    }
    
    var presentedDate: Date! {
        didSet {
            if let oldValue = oldValue {
                delegate?.presentedDateUpdated?(presentedDate)
            }
        }
    }
    
    // MARK: - Calendar View Delegate
    
    @IBOutlet weak var calendarDelegate: AnyObject? {
        set {
            if let calendarDelegate = newValue as? Delegate {
                delegate = calendarDelegate
            }
        }
        
        get {
            return delegate
        }
    }
    
    var delegate: CVCalendarViewDelegate? {
        didSet {
            if manager == nil {
                manager = Manager(calendarView: self)
            }
            
            if appearance == nil {
                appearance = Appearance()
            }
            
            if touchController == nil {
                touchController = TouchController(calendarView: self)
            }
            
            if coordinator == nil {
                coordinator = Coordinator(calendarView: self)
            }
            
            if animator == nil {
                animator = Animator(calendarView: self)
            }
            
            if calendarMode == nil {
                loadCalendarMode()
            }
        }
    }
    
    // MARK: - Calendar Appearance Delegate
    
    @IBOutlet weak var calendarAppearanceDelegate: AnyObject? {
        set {
            if let calendarAppearanceDelegate = newValue as? AppearanceDelegate {
                if appearance == nil {
                    appearance = Appearance()
                }
                
                appearance.delegate = calendarAppearanceDelegate
            }
        }
        
        get {
            return appearance
        }
    }
    
    // MARK: - Calendar Animator Delegate
    
    @IBOutlet weak var animatorDelegate: AnyObject? {
        set {
            if let animatorDelegate = newValue as? AnimatorDelegate {
                animator.delegate = animatorDelegate
            }
        }
        
        get {
            return animator
        }
    }
    
    // MARK: - Initialization
    
    init() {
        super.init(frame: CGRect.zero)
        isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
    }

    /// IB Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        isHidden = true
    }
}

// MARK: - Frames update

extension CVCalendarView {
    func commitCalendarViewUpdate() {
        if let delegate = delegate, let contentController = contentController {
            let contentViewSize = contentController.bounds.size
            let selfSize = bounds.size
            
            if !validated {
                let width = selfSize.width
                let height: CGFloat
                let countOfWeeks = CGFloat(5)
                
                let vSpace = appearance.spaceBetweenWeekViews!
                let hSpace = appearance.spaceBetweenDayViews!
                
                if let mode = calendarMode {
                    switch mode {
                    case .weekView:
                        height = selfSize.height
                    case .monthView :
                        height = (selfSize.height / countOfWeeks) - (vSpace * countOfWeeks)
                    }
                    
                    
                    weekViewSize = CGSize(width: width, height: height)
                    dayViewSize = CGSize(width: (width / 7.0) - hSpace, height: height)
                    validated = true
                    
                    contentController.updateFrames(selfSize != contentViewSize ? bounds : CGRect.zero)
                }
            }
        }
    }
}

// MARK: - Coordinator callback

extension CVCalendarView {
    func didSelectDayView(_ dayView: CVCalendarDayView) {
        if let controller = contentController {
            presentedDate = dayView.date
            delegate?.didSelectDayView?(dayView)
            controller.performedDayViewSelection(dayView) // TODO: Update to range selection
        }
    }
}

// MARK: - Convenience API

extension CVCalendarView {
    func changeDaysOutShowingState(_ shouldShow: Bool) {
        contentController.updateDayViews(shouldShow)
    }
    
    func toggleViewWithDate(_ date: Foundation.Date) {
        contentController.togglePresentedDate(date)
    }
    
    func toggleCurrentDayView() {
        contentController.togglePresentedDate(Foundation.Date())
    }
    
    func loadNextView() {
        contentController.presentNextView(nil)
    }
    
    func loadPreviousView() {
        contentController.presentPreviousView(nil)
    }
    
    func changeMode(_ mode: CalendarMode) {
        if let selectedDate = coordinator.selectedDayView?.date.convertedDate(), calendarMode != mode {
            calendarMode = mode
            
            let newController: ContentController
            switch mode {
            case .weekView:
                contentController.updateHeight(dayViewSize!.height, animated: true)
                newController = WeekContentViewController(calendarView: self, frame: bounds, presentedDate: selectedDate)
            case .monthView:
                contentController.updateHeight(contentController.presentedMonthView.potentialSize.height, animated: true)
                newController = MonthContentViewController(calendarView: self, frame: bounds, presentedDate: selectedDate)
            }
            
            
            newController.updateFrames(bounds)
            newController.scrollView.alpha = 0
            addSubview(newController.scrollView)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.contentController.scrollView.alpha = 0
                newController.scrollView.alpha = 1
            }) { _ in
                self.contentController.scrollView.removeAllSubviews()
                self.contentController.scrollView.removeFromSuperview()
                self.contentController = newController
            }
        }
    }
}

// MARK: - Mode load 

private extension CVCalendarView {
    func loadCalendarMode() {
        if let delegate = delegate {
            calendarMode = delegate.presentationMode()
            switch delegate.presentationMode() {
                case .monthView: contentController = MonthContentViewController(calendarView: self, frame: bounds)
                case .weekView: contentController = WeekContentViewController(calendarView: self, frame: bounds)
                default: break
            }
            
            addSubview(contentController.scrollView)
        }
    }
}
