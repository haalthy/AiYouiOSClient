//
//  CVAuxiliaryView.swift
//  CVCalendar Demo
//
//  Created by Eugene Mozharovsky on 22/03/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class CVAuxiliaryView: UIView {
    var shape: CVShape!
    var strokeColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var fillColor: UIColor! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let defaultFillColor = UIColor.colorFromCode(0xe74c3c)
    
    fileprivate var radius: CGFloat {
        get {
            return (min(frame.height, frame.width) - 10) / 2
        }
    }
    
    unowned let dayView: DayView
    
    init(dayView: DayView, rect: CGRect, shape: CVShape) {
        self.dayView = dayView
        self.shape = shape
        super.init(frame: rect)
        strokeColor = UIColor.clear
        fillColor = UIColor.colorFromCode(0xe74c3c)
        
        layer.cornerRadius = 5
        backgroundColor = .clear
    }
    
    override func didMoveToSuperview() {
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        var path: UIBezierPath!
        
        if let shape = shape {
            switch shape {
            case .rightFlag: path = rightFlagPath()
            case .leftFlag: path = leftFlagPath()
            case .circle: path = circlePath()
            case .rect: path = rectPath()
            }
        }
        
        strokeColor.setStroke()
        fillColor.setFill()
        
        if let path = path {
            path.lineWidth = 1
            path.stroke()
            path.fill()
        }
    }
    
    deinit {
    }
}

extension CVAuxiliaryView {
    func updateFrame(_ frame: CGRect) {
        self.frame = frame
        setNeedsDisplay()
    }
}

extension CVAuxiliaryView {
    func circlePath() -> UIBezierPath {
        let arcCenter = CGPoint(x: frame.width / 2, y: frame.height / 2)
        let startAngle = CGFloat(0)
        let endAngle = CGFloat(M_PI * 2.0)
        let clockwise = true
        
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        return path
        
    }
    
    func rightFlagPath() -> UIBezierPath {
        let appearance = dayView.calendarView.appearance
        let offset = appearance?.spaceBetweenDayViews!
        
        let flag = UIBezierPath()
        flag.move(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 - radius))
        flag.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2 - radius))
        flag.addLine(to: CGPoint(x: bounds.width, y: bounds.height / 2 + radius ))
        flag.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 + radius))
        
        let path = CGMutablePath()
//        CGPathAddPath(path, nil, circlePath().cgPath)
//        CGPathAddPath(path, nil, flag.cgPath)
        path.addPath(circlePath().cgPath)
        path.addPath(flag.cgPath)
        
        return UIBezierPath(cgPath: path)
    }
    
    func leftFlagPath() -> UIBezierPath {
        let flag = UIBezierPath()
        flag.move(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 + radius))
        flag.addLine(to: CGPoint(x: 0, y: bounds.height / 2 + radius))
        flag.addLine(to: CGPoint(x: 0, y: bounds.height / 2 - radius))
        flag.addLine(to: CGPoint(x: bounds.width / 2, y: bounds.height / 2 - radius))
        
        let path = CGMutablePath()
//        CGPathAddPath(path, nil, circlePath().cgPath)
//        CGPathAddPath(path, nil, flag.cgPath)
        path.addPath(circlePath().cgPath)
        path.addPath(flag.cgPath)
        return UIBezierPath(cgPath: path)
    }
    
    func rectPath() -> UIBezierPath {
        let midX = bounds.width / 2
        let midY = bounds.height / 2
        
        let appearance = dayView.calendarView.appearance
        let offset = appearance?.spaceBetweenDayViews!
                
        let path = UIBezierPath(rect: CGRect(x: 0 - offset!, y: midY - radius, width: bounds.width + offset! / 2, height: radius * 2))
        
        return path
    }
}
