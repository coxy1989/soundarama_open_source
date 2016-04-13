//
//  ChargerView.swift
//  Soundarama
//
//  Created by Jamie Cox on 13/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class ChargerView: UIView {
    
    private lazy var movingCircle: UIView = {
        
        let v = CircleView()
        v.backgroundColor = UIColor.orangeColor()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var fixedCircle: UIView = {
        
        let v = BorderedCircleView()
        v.backgroundColor = UIColor.purpleColor()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
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
        addSubview(fixedCircle)
        addSubview(movingCircle)
        backgroundColor = UIColor.redColor()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        fixedCircle.frame = bounds
        movingCircle.frame = bounds
    }
    
    func setValue(value: Double) {
        
        UIView.animateWithDuration(1) { [weak self] in
            
            self?.movingCircle.transform = CGAffineTransformMakeScale(1.5, 1.5)
        }
    }
}

class CircleView: UIView {
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let sl0 = CAShapeLayer()
        sl0.fillColor = UIColor.grayColor().CGColor
        layer.addSublayer(sl0)
        sl0.path = UIBezierPath(ovalInRect: bounds).CGPath
    }
}

class BorderedCircleView: UIView {
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        let l = CAShapeLayer()
        l.fillColor = UIColor.clearColor().CGColor
        l.lineWidth = 3.0
        l.strokeColor = UIColor.whiteColor().CGColor
        l.lineDashPattern = [ 5, 9 ]
        layer.addSublayer(l)
        l.path = UIBezierPath(ovalInRect: bounds).CGPath
    }
}