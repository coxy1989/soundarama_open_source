//
//  ChargerView.swift
//  Soundarama
//
//  Created by Jamie Cox on 13/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

// TODO: apply gradient to the dotted line

class CircleView: UIView {
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let sl0 = CAShapeLayer()
        sl0.fillColor = UIColor.grayColor().CGColor
        layer.addSublayer(sl0)
        sl0.path = UIBezierPath(ovalInRect: bounds).CGPath
    }
}

class ChargeLevelView: UIView {
    
    private var colors: [UIColor]?
    
    private lazy var dashed_layer : CAShapeLayer = {
        
        let l = CAShapeLayer()
        l.fillColor = UIColor.clearColor().CGColor
        l.lineWidth = 4
        l.strokeColor = UIColor.whiteColor().CGColor
        l.lineDashPattern = [ 0, l.lineWidth * 3]
        l.lineCap = "round"
        return l
    }()
    
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
        layer.addSublayer(dashed_layer)
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        dashed_layer.path = UIBezierPath(ovalInRect: CGRectInset(bounds, 10, 10)).CGPath
    }
    
    func setColors(colors: [UIColor]) {

        self.colors = colors
    }
    
    func setUnderColor() {
        
        dashed_layer.strokeColor = UIColor.whiteColor().colorWithAlphaComponent(0.5).CGColor
    }
    
    func setOverColor() {
        
        dashed_layer.strokeColor = colors?[3].CGColor ?? UIColor.whiteColor().CGColor
    }
}

class ChargeGradientView: UIView {
    
    override class func layerClass() -> AnyClass {
        
        return CAGradientLayer.self
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width * 0.5
    }
    
    private func commonInit() {
        
        (layer as! CAGradientLayer).startPoint = CGPoint(x: 0, y: 0)
        (layer as! CAGradientLayer).endPoint = CGPoint(x: 0, y: 1)
    }
    
    func setColors(colors: [UIColor]) {
        
        (layer as! CAGradientLayer).colors = [colors[0], colors[4] ].map() { $0.CGColor }
    }
}
