//
//  DJViewController.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJViewController: UIViewController
{
    private var server: SoundaramaServer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.server = SoundaramaServer()
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        self.server?.publishService()
    }
}
