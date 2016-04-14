//
//  LevelCompassView.swift
//  Soundarama
//
//  Created by Jamie Cox on 11/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class CompassView: UIView {
    
    private lazy var north_point: UIView = {
       
        let v = UIView()
        v.backgroundColor = UIColor.whiteColor()
        v.frame.size = CGSizeMake(40, 40)
        v.layer.cornerRadius = 20
        v.clipsToBounds = false
        return v
    }()
    
    private lazy var south_point: UIView = {
        
        let v = UIView()
        v.backgroundColor = UIColor.whiteColor()
        v.frame.size = CGSizeMake(40, 40)
        v.layer.cornerRadius = 20
        v.clipsToBounds = false
        return v
    }()
    
    private lazy var circle_layer: CAShapeLayer = {
        
        let l = CAShapeLayer()
        l.lineWidth = 2
        l.fillColor = UIColor.clearColor().CGColor
        l.strokeColor = UIColor.whiteColor().CGColor
        return l
    }()
    
    func setColor(color: UIColor) {
        
        north_point.backgroundColor = color
        south_point.backgroundColor = color
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        
        clipsToBounds = false
        addSubview(north_point)
        addSubview(south_point)
        layer.addSublayer(circle_layer)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        circle_layer.path = UIBezierPath(ovalInRect: bounds).CGPath
        north_point.center = CGPointMake(bounds.size.width * 0.5, 0)
        south_point.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height)
    }
}
