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
    private var djButtonBackgroundImageView: UIImageView?
    
    private var performerButton: UIButton?
    private var performerBackgroundImageView: UIImageView?
    
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
        
        self.djButtonBackgroundImageView = UIImageView()
        self.djButtonBackgroundImageView?.image = UIImage(named: "bg-home-dj")
        self.djButtonBackgroundImageView?.contentMode = .ScaleAspectFill
        self.view.addSubview(self.djButtonBackgroundImageView!)
        
        self.djButton = UIButton()
        self.djButton?.setTitle(NSLocalizedString("HOME_DJ", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.djButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.djButton?.titleLabel?.font = UIFont.soundaramaSansSerifHeavyFont(size: 24)
        self.djButton?.addTarget(self, action: "didPressDJButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.djButton!)
        
        self.performerBackgroundImageView = UIImageView()
        self.performerBackgroundImageView?.image = UIImage(named: "bg-home-performer")
        self.performerBackgroundImageView?.contentMode = .ScaleAspectFill
        self.view.addSubview(self.performerBackgroundImageView!)
        
        self.performerButton = UIButton()
        self.performerButton?.setTitle(NSLocalizedString("HOME_PERFORMER", comment: "").uppercaseString, forState: UIControlState.Normal)
        self.performerButton?.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.performerButton?.titleLabel?.font = UIFont.soundaramaSansSerifHeavyFont(size: 24)
        self.performerButton?.addTarget(self, action: "didPressPerformerButton:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(self.performerButton!)
        
        self.view.backgroundColor = UIColor.blackColor()
    }
    
    override func viewWillLayoutSubviews()
    {
        super.viewWillLayoutSubviews()
        
        self.performerButton?.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.width / 2.0, height: self.view.bounds.height)
        self.performerBackgroundImageView?.frame = self.performerButton!.frame
        
        self.djButton?.frame = CGRect(x: (self.view.bounds.width / 2.0), y: 0.0, width: self.view.bounds.width / 2.0, height: self.view.bounds.height)
        self.djButtonBackgroundImageView?.frame = self.djButton!.frame
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