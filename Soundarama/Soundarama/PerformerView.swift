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
        
        let insetFrame = CGRectInset(frame, -14.0, -14.0)
        
        super.init(frame: insetFrame)
        image = UIImage(named: "icn-phone")
        contentMode = .Center
        sizeToFit()
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}

typealias GroupView = PerformerView