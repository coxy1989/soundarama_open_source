//
//  LevelCompassView.swift
//  Soundarama
//
//  Created by Jamie Cox on 11/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class LevelCompassView: UIView {
    
    private var level: Level = .Middle
    
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
    
    func setColor(color: UIColor) {
        
        north_point.backgroundColor = color
        south_point.backgroundColor = color
    }
    
    func setLevel(level: Level) {
        
        guard self.level != level else {
            
            return
        }
        
        UIView.animateWithDuration(0.5) { [weak self] in
            
            guard let this = self else {
                
                return
            }
            
            this.north_point.center = CGPointMake(this.bounds.size.width * 0.5, this.level_y(level))
            this.south_point.center = CGPointMake(this.bounds.size.width * 0.5, this.bounds.size.height - this.level_y(level))
        }
        
        self.level = level
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
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let n: CGFloat = 3
        let c0: CGFloat = 0.49
        let c1 = 0.5 - (0.5 / n)
        let c2 = c1 - (0.5 / n)
        let c3 = c2 - (0.5 / n)
        
        let sl0 = CAShapeLayer()
        sl0.lineWidth = 2
        sl0.strokeColor = UIColor.whiteColor().CGColor
        sl0.fillColor = UIColor.whiteColor().CGColor
        layer.addSublayer(sl0)
        sl0.path = UIBezierPath(ovalInRect: CGRectInset(bounds, bounds.size.width * c0, bounds.size.height * c0)).CGPath
        
        let sl1 = CAShapeLayer()
        sl1.lineWidth = 2
        sl1.fillColor = UIColor.clearColor().CGColor
        sl1.strokeColor = UIColor.whiteColor().CGColor
        layer.addSublayer(sl1)
        sl1.path = UIBezierPath(ovalInRect: CGRectInset(bounds, bounds.size.width * c1, bounds.size.height * c1)).CGPath
        
        let sl2 = CAShapeLayer()
        sl2.lineWidth = 2
        sl2.fillColor = UIColor.clearColor().CGColor
        sl2.strokeColor = UIColor.whiteColor().CGColor
        layer.addSublayer(sl2)
        sl2.path = UIBezierPath(ovalInRect: CGRectInset(bounds, bounds.size.width * c2, bounds.size.height * c2)).CGPath
        
        let sl3 = CAShapeLayer()
        sl3.lineWidth = 2
        sl3.fillColor = UIColor.clearColor().CGColor
        sl3.strokeColor = UIColor.whiteColor().CGColor
        layer.addSublayer(sl3)
        sl3.path = UIBezierPath(ovalInRect: CGRectInset(bounds, bounds.size.width * c3, bounds.size.height * c3)).CGPath
        
        
        north_point.center = CGPointMake(bounds.size.width * 0.5, level_y(level))
        south_point.center = CGPointMake(bounds.size.width * 0.5, bounds.size.height - level_y(level))
    }
    
    private func level_y(level: Level) -> CGFloat {
        
        switch level {
            
            case .Low:
                
                return (2 * ((bounds.size.height / 3) / 2))
            
            case .Middle:
                
                return ((bounds.size.height / 3) / 2)
            
            case .High:
                
                return 0
        }
    }
}
