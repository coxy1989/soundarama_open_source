//
//  LevelCompassView.swift
//  Soundarama
//
//  Created by Jamie Cox on 11/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

private struct Layout {
    
    static let compass_point_diameter: CGFloat = 40
    
    static let compass_gradient_width: CGFloat = 3
}

class CompassView: UIView {
    
    private let circle_layer = CAShapeLayer()
    
    private lazy var north_point: UIView = {
       
        let v = UIView()
        v.frame.size = CGSizeMake(Layout.compass_point_diameter, Layout.compass_point_diameter)
        v.layer.cornerRadius = Layout.compass_point_diameter * 0.5
        v.clipsToBounds = false
        return v
    }()
    
    private lazy var south_point: UIView = {
        
        let v = UIView()
        v.frame.size = CGSizeMake(Layout.compass_point_diameter, Layout.compass_point_diameter)
        v.layer.cornerRadius = Layout.compass_point_diameter * 0.5
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
    
        let side = min (bounds.size.height, bounds.size.width) - Layout.compass_point_diameter
        let x = (bounds.size.width - side) * 0.5
        let y = (bounds.size.height - side) * 0.5

        circle_gradient_layer.frame = CGRectMake(x, y, side, side)
        circle_gradient_layer.cornerRadius = side * 0.5
        
        circle_layer.path = UIBezierPath(ovalInRect: CGRectInset(bounds, x + Layout.compass_gradient_width, y + Layout.compass_gradient_width)).CGPath
        
        north_point.center = CGPointMake(x + (side * 0.5), y)
        south_point.center = CGPointMake(x + (side * 0.5), y + side)
    }
    
    func setPointsHidden(value: Bool) {
        
        [north_point, south_point].forEach() { $0.hidden = value }
    }
    
    override func intrinsicContentSize() -> CGSize {
        
        let side = min (bounds.size.height, bounds.size.width) - Layout.compass_point_diameter
        return CGSizeMake(side, side)
    }
}
