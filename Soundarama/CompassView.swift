//
//  CompassView.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class CompassView: UIView {
    
    private lazy var circle: UIView = {
        
        let v = UIView()
        v.backgroundColor = UIColor.lightGrayColor()
        v.alpha = 0.65
        return v
    }()
    
    private lazy var north: UIView = {
        
        let v = UIView()
        v.backgroundColor = UIColor.lightGrayColor()
        return v
    }()
    
    private lazy var south: UIView = {
        
        let v = UIView()
        v.backgroundColor = UIColor.lightGrayColor()
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
}

extension CompassView {
    
    private func commonInit() {
       
        addSubview(circle)
        addSubview(north)
        addSubview(south)
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        circle.frame = CGRectInset(bounds, 60, 60)
        circle.layer.cornerRadius = circle.frame.size.width * 0.5
        
        north.frame.origin = CGPointMake(circle.center.x - 30, circle.frame.origin.y - 30)
        north.frame.size = CGSizeMake(60, 60)
        north.layer.cornerRadius = north.frame.size.width * 0.5
        
        south.frame.origin = CGPointMake(circle.center.x - 30, circle.frame.origin.y + circle.frame.size.height - 30)
        south.frame.size = CGSizeMake(60, 60)
        south.layer.cornerRadius = north.frame.size.width * 0.5
    }
}