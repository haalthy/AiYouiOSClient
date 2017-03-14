//
//  CVCalendarDayViewControlCoordinator.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

class CVCalendarDayViewControlCoordinator {
    // MARK: - Non public properties
    fileprivate var selectionSet = Set<DayView>()
    fileprivate unowned let calendarView: CalendarView
    
    // MARK: - Public properties
    weak var selectedDayView: CVCalendarDayView?
    var animator: CVCalendarViewAnimator! {
        get {
            return calendarView.animator
        }
    }

    // MARK: - initialization
    init(calendarView: CalendarView) {
        self.calendarView = calendarView
    }
}

// MARK: - Animator side callback

extension CVCalendarDayViewControlCoordinator {
    func selectionPerformedOnDayView(_ dayView: DayView) {
        // TODO:
    }
    
    func deselectionPerformedOnDayView(_ dayView: DayView) {
        if dayView != selectedDayView {
            selectionSet.remove(dayView)
            dayView.setDeselectedWithClearing(true)
        }
    }
    
    func dequeueDayView(_ dayView: DayView) {
        selectionSet.remove(dayView)
    }
    
    func flush() {
        selectedDayView = nil
        selectionSet.removeAll()
    }
}

// MARK: - Animator reference 

private extension CVCalendarDayViewControlCoordinator {
    func presentSelectionOnDayView(_ dayView: DayView) {
        animator.animateSelectionOnDayView(dayView)
        //animator?.animateSelection(dayView, withControlCoordinator: self)
    }
    
    func presentDeselectionOnDayView(_ dayView: DayView) {
        animator.animateDeselectionOnDayView(dayView)
        //animator?.animateDeselection(dayView, withControlCoordinator: self)
    }
}

// MARK: - Coordinator's control actions

extension CVCalendarDayViewControlCoordinator {
    func performDayViewSingleSelection(_ dayView: DayView) {
        selectionSet.insert(dayView)
        
        if selectionSet.count > 1 {
            let count = selectionSet.count-1
            for dayViewInQueue in selectionSet {
                if dayView != dayViewInQueue {
                    if dayView.calendarView != nil {
                        presentDeselectionOnDayView(dayViewInQueue)
                    }
                    
                }
                
            }
        }
        
        if let animator = animator {
            if selectedDayView != dayView {
                selectedDayView = dayView
                presentSelectionOnDayView(dayView)
            }
        } 
    }
    
    func performDayViewRangeSelection(_ dayView: DayView) {
        print("Day view range selection found")
    }
}
