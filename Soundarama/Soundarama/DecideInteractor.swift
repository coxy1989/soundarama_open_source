//
//  DecideInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import Foundation

class DecideInteractor {
    
}

/*

class RootViewController: UINavigationController {
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        if let lastVC = self.viewControllers.last {
            if lastVC is HomeViewController {
                return [ UIInterfaceOrientationMask.Landscape, UIInterfaceOrientationMask.Portrait ]
            }
            else if lastVC is PerformerViewController {
                return [ UIInterfaceOrientationMask.Portrait ]
            }
            else if lastVC is DJViewController {
                return [ UIInterfaceOrientationMask.Landscape ]
            }
        }
        
        return [ UIInterfaceOrientationMask.Landscape ]
    }
}


    func setupNavigation() {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            self.window?.rootViewController = RootViewController(rootViewController: HomeViewController(nibName: nil, bundle: nil))
        }
        else {
            self.window?.rootViewController = RootViewController(rootViewController: PerformerViewController(nibName: nil, bundle: nil))
        }
        self.window?.makeKeyAndVisible()
        self.window?.backgroundColor = UIColor.whiteColor()
    }

*/