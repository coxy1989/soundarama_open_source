//
//  PerformerPhoneImageView.swift
//  Soundarama
//
//  Created by Tom Weightman on 09/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import Foundation
import UIKit

class PerformerPhoneImageView: UIImageView
{
    var performerID: String?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }

    override init(image: UIImage?)
    {
        super.init(image: image)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}