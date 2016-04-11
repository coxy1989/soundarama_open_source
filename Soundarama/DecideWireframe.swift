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
        nvc.setViewControllers([decideViewController()], animated: false)
    }
    
    func decide(decision: Decision) {
        
        decision == .DJ ? djModule.start(nvc) : performerModule.start(nvc)
    }
}

extension DecideWireframe {
    
    private func decideViewController() -> UIViewController {
        
        let vc = UIDevice.isPad() ? decideViewController_iPad() : decideViewController_iPhone()
        vc.delegate = decidePresenter
        return vc
    }
    
    private func decideViewController_iPad() -> DecideViewController {
        
        let sb = UIStoryboard(name: "DecideStoryboard", bundle: NSBundle.mainBundle())
        return sb.instantiateViewControllerWithIdentifier("DecideViewController_iPad") as! DecideViewController
    }
    
    private func decideViewController_iPhone() -> DecideViewController {
        
        let sb = UIStoryboard(name: "DecideStoryboard", bundle: NSBundle.mainBundle())
        return sb.instantiateViewControllerWithIdentifier("DecideViewController_iPhone") as! DecideViewController
    }
}
