//
//  PerformerViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class PerformerViewController: UIViewController, PerformerUserInterface {
    
    weak var delegate: PerformerUserInterfaceDelegate!
    
    struct Strings {
        
        static let Connected = "Connecté"
        static let NotConnected = "Non Connecté"
    }
    
    @IBOutlet weak var imageView: UIImageView?
    
    @IBOutlet weak var label: UILabel?
    
    override func viewDidLoad() {
        
        delegate.ready()
    }
    
    func setConnectionState(state: ConnectionState) {
        
        if state == .Connected {
            label?.text = Strings.Connected
        } else if state == .NotConnected {
            label?.text = Strings.NotConnected
        }
    }
    
    func setColour(colour: UIColor?) {
        
        imageView?.backgroundColor = colour ?? UIColor.blackColor()
        label?.textColor = colour ?? UIColor.blackColor()
    }
}

/*

private lazy var backgroundImages: [UIImage] =
-    {
-        var images = [UIImage]()
-        let numberOfImages = 4
-        for i in 1...numberOfImages
-        {
-            let imageFileName = "glitch-\(i).jpg"
-            images.append(UIImage(named: imageFileName)!)
-        }
-        return images
-    }()
-    private var backgroundImageIdx = 0

private func progressToNextBackgroundImage()
-    {
-        self.backgroundImageIdx++
-        if (self.backgroundImageIdx > self.backgroundImages.count - 1)
-        {
-            self.backgroundImageIdx = 0
-        }
-
-        self.backgroundImageView?.image = self.backgroundImages[self.backgroundImageIdx]
-    }
*/