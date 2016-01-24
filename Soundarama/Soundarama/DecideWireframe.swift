//
//  DecideWireframe.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DecideWireframe {
    
    enum Decision {
        case DJ, Performer
    }
    
    weak var decidePresenter: DecidePresenter!
    
    weak var performerModule: PerformerModule!
    
    weak var djModule: DJModule!
    
    private let window: UIWindow!
    
    private lazy var nvc: UINavigationController = {
        let nvc = UINavigationController()
        nvc.setNavigationBarHidden(true, animated: false)
        return nvc
    }()
    
    init(window: UIWindow) {
        
        self.window = window
    }
    
    func presentUI() {
        
        window.rootViewController = nvc
        window.makeKeyAndVisible()
        isPad() ? nvc.setViewControllers([decideViewController()], animated: false) : performerModule.start(nvc)
    }
    
    func decide(decision: Decision) {
        
        if decision == .DJ {
            djModule.start(nvc)
        } else if decision == .Performer {
            performerModule.start(nvc)
        }
    }
}

extension DecideWireframe {
    
    private func isPad() -> Bool {
        
        return UIDevice.currentDevice().userInterfaceIdiom == .Pad
    }
    
    private func decideViewController() -> UIViewController {
        
        let sb = UIStoryboard(name: "DecideStoryboard", bundle: NSBundle.mainBundle())
        let vc = sb.instantiateViewControllerWithIdentifier("DecideViewController") as! DecideViewController
        vc.delegate = decidePresenter
        return vc
    }
}
