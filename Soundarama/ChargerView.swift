//
//  ChargerView.swift
//  Soundarama
//
//  Created by Jamie Cox on 13/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

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
    
    private struct Dot {
        
        static let diameter: CGFloat = 4
        
        static let spacing: CGFloat = Dot.diameter * 3
    }
    
    private var colors: [UIColor]?
    
    private var dots: [UIView]?
    
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
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
    
        let side = min (bounds.size.height, bounds.size.width)
        let radius = CGFloat((side * 0.5) - (Dot.diameter * 0.5))
        let circum = 2 * CGFloat(M_PI) * radius
        let num = Int(round((circum / (Dot.diameter + Dot.spacing))))
        
        let r: Range<Int> = 0..<num
        
        let vs: [UIView] = r.map() { _ in
            
            let v = UIView()
            v.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            v.frame.size.height = Dot.diameter
            v.frame.size.width = Dot.diameter
            v.layer.cornerRadius = (Dot.diameter * 0.5)
            return v
        }
        
        dots = vs
        layoutDots(vs, radius: radius)
    }
    
    func setColors(colors: [UIColor]) {

        self.colors = colors
    }
    
    func setUnderColor() {
        
        dots?.forEach() { $0.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5) }
    }
    
    func setOverColor() {
        
        dots?.forEach() { v in  v.backgroundColor =  colors?[3] ?? UIColor.whiteColor() }
    }
    
    func layoutDots(dots: [UIView], radius: CGFloat) {
        
        let center = CGPointMake(bounds.width/2 ,bounds.height/2)
    
        var angle = CGFloat(2 * M_PI)
        let step = CGFloat(2 * M_PI) / CGFloat(dots.count)
        
        dots.forEach() {
            
            let x = cos(angle) * radius + center.x
            let y = sin(angle) * radius + center.y
            
            
            
            $0.center.x = x
            $0.center.y = y
            
            addSubview($0)
            angle += step
        }
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
