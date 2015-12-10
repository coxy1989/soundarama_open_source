//
//  DeviceTrayView.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

class DeviceTrayView: UIView
{
    private var titleLabel: UILabel
    private var backgroundImageView: UIImageView
    
    override init(frame: CGRect)
    {
        self.backgroundImageView = UIImageView()
        self.backgroundImageView.image = UIImage(named: "bg-device-tray")
        self.backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        self.titleLabel = UILabel()
        self.titleLabel.text = NSLocalizedString("DEVICES", comment: "Devices")
        self.titleLabel.font = UIFont.soundaramaSansSerifRomanFont(size: 18)
        self.titleLabel.textColor = UIColor.lightGrayColor()
        self.titleLabel.textAlignment = .Center
        
        super.init(frame: frame)
        
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.titleLabel)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.backgroundImageView.frame = self.bounds
        self.titleLabel.frame = CGRect(x: 0.0, y: 0.0, width: self.bounds.width, height: 50.0)
    }
    
}