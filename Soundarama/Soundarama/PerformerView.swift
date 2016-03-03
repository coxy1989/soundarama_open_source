//
//  PerformerPhoneImageView.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit

class PerformerView: UIImageView {
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        image = UIImage(named: "icn-phone")
        contentMode = .Center
        sizeToFit()
        self.frame = CGRectInset(self.frame, -20, -20)
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

typealias GroupView = PerformerView