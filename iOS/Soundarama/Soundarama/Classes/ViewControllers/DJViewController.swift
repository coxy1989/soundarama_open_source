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
    private let server = SoundaramaServer()
    
    private var displayLink: CADisplayLink!
    
    private lazy var testButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Test", forState: .Normal)
        button.addTarget(self, action: Selector("testButtonWasPressed"), forControlEvents: .TouchUpInside)
        return button
    }()
    
    private lazy var testLabel: UILabel = { [unowned self] in
        let label = UILabel()
        label.textColor = UIColor.whiteColor()
        label.text = "\(NSDate().timeIntervalSince1970)"
        return label
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        view.addSubview(testButton)
        view.addSubview(testLabel)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        
        server.publishService()
        displayLink = CADisplayLink(target: self, selector: "displayLinkDidFire")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        testButton.sizeToFit()
        testButton.center = view.center
        testLabel.sizeToFit()
        testLabel.frame.origin = CGPointMake(0, 0)
    }
    
    @objc func testButtonWasPressed() {
        let message = Message(soundID: 23, timestamp: NSDate().timeIntervalSince1970, loopLength: 2)
        server.sendMessage(message)
    }
}

extension DJViewController {
    
    func displayLinkDidFire() {
        testLabel.text = String(NSString(format: "%.02f", NSDate().timeIntervalSince1970))
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
