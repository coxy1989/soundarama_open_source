//
//  ViewController.swift
//  Soundarama
//
//  Created by Tom Weightman on 13/11/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

import UIKit

import UIKit

class HomeViewController: UIViewController
{
    private var djButton: UIButton?
    private var performerButton: UIButton?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.djButton = UIButton()
        self.djButton?.setTitle("DJ", forState: UIControlState.Normal)
        self.djButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.djButton?.addTarget(self, action: "didPressDJButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.djButton!)
        
        self.performerButton = UIButton()
        self.performerButton?.setTitle("Performer", forState: UIControlState.Normal)
        self.performerButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.performerButton?.addTarget(self, action: "didPressPerformerButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.performerButton!)
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        self.djButton?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width, height: self.view.bounds.height / 2.0)
        self.performerButton?.frame = CGRect(x: 0.0, y: self.view.bounds.height / 2.0, width: self.view.bounds.width, height: self.view.bounds.height / 2.0)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func didPressDJButton(button: UIButton)
    {
        let vc = DJViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didPressPerformerButton(button: UIButton)
    {
        let vc = PerformerViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}