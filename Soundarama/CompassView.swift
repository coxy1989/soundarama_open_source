//
//  LevelCompassView.swift
//  Soundarama
//
//  Created by Jamie Cox on 11/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class CompassView: UIView {
    
    private let circle_layer = CAShapeLayer()
    
    private lazy var north_point: UIView = {
       
        let v = UIView()
        v.frame.size = CGSizeMake(40, 40)
        v.layer.cornerRadius = 20
        v.clipsToBounds = false
        return v
    }()
    
    private lazy var south_point: UIView = {
        
        let v = UIView()
        v.frame.size = CGSizeMake(40, 40)
        v.layer.cornerRadius = 20
        v.clipsToBounds = false
        return v
    }()
    
    private lazy var circle_gradient_layer: CAGradientLayer = {
        
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0, y: 0)
        l.endPoint = CGPoint(x: 0, y: 1)
        return l
    }()
    
    func setColors(colors: [UIColor]) {
        
        north_point.backgroundColor = colors[0]
        circle_layer.fillColor = colors[3].CGColor
        south_point.backgroundColor = colors[4]
        circle_gradient_layer.colors = [colors[0], colors[4] ].map() { $0.colorWithAlphaComponent(0.4).CGColor }
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
        layer.addSublayer(circle_gradient_layer)
        layer.addSublayer(circle_layer)
        addSubview(north_point)
        addSubview(south_point)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        circle_gradient_layer.frame = bounds
        circle_gradient_layer.cornerRadius = bounds.size.width * 0.5
        circle_layer.path = UIBezierPath(ovalInRect: CGRectInset(bounds, 3, 3)).CGPath
        north_point.center = CGPointMake(bounds.size.width * 0.5, 0)
        south_point.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height)
    }
    
    func setPointsHidden(value: Bool) {
        
        [north_point, south_point].forEach() { $0.hidden = value }
    }
}
