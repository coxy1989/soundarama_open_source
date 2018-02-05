//
//  UnderlinedTextButton.swift
//  Soundarama
//
//  Created by Jamie Cox on 15/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class UnderlinedTextButton: UIButton {
    
    private var underline: UIView  = UIView()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        commonInit()
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        underline.frame = CGRectMake(0, bounds.size.height - 1, bounds.size.width, 1)
    }
    
    func setUnderlineColor(color: UIColor?) {
        
        underline.backgroundColor = color
    }
}

extension UnderlinedTextButton {
    
    private func commonInit() {
        
        addSubview(underline)
    }
}