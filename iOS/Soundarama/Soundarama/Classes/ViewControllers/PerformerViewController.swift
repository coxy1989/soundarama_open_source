//
//  PerformerViewController.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit

class PerformerViewController: UIViewController
{
    private var client: SoundaramaClient?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.client = SoundaramaClient()
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        self.client?.connectToServer()
    }
}
