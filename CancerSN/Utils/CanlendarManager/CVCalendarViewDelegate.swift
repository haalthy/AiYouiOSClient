//
//  CVCalendarViewDelegate.swift
//  CVCalendar
//
//  Created by E. Mozharovsky on 12/27/14.
//  Copyright (c) 2014 GameApp. All rights reserved.
//

import UIKit

@objc
protocol CVCalendarViewDelegate {
    func presentationMode() -> CalendarMode
    func firstWeekday() -> Weekday
    
    @objc optional func shouldShowWeekdaysOut() -> Bool
    @objc optional func didSelectDayView(_ dayView: DayView)
    @objc optional func presentedDateUpdated(_ date: Date)
    @objc optional func topMarker(shouldDisplayOnDayView dayView: DayView) -> Bool
    @objc optional func dotMarker(shouldMoveOnHighlightingOnDayView dayView: DayView) -> Bool
    @objc optional func dotMarker(shouldShowOnDayView dayView: DayView) -> Bool
    @objc optional func dotMarker(colorOnDayView dayView: DayView) -> [UIColor]
    @objc optional func dotMarker(moveOffsetOnDayView dayView: DayView) -> CGFloat
    
    @objc optional func preliminaryView(viewOnDayView dayView: DayView) -> UIView
    @objc optional func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
    
    @objc optional func supplementaryView(viewOnDayView dayView: DayView) -> UIView
    @objc optional func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
}
