//
//  AutoLayout.swift
//  TouchpressKit
//
//  Created by Karim Sallam on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func fillSubview(subview: UIView) {
        
        fillSubview(subview, inset: UIEdgeInsetsZero)
    }
    
    public func fillSubview(subview: UIView, inset: UIEdgeInsets) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        let views = ["subview" : subview]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(inset.top)-[subview]-\(inset.bottom)-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-\(inset.left)-[subview]-\(inset.right)-|", options: NSLayoutFormatOptions(), metrics: nil, views: views))
    }
}
