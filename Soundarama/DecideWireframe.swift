//
//  DecideWireframe.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DecideWireframe {
    
    private let window: UIWindow!
    
    lazy var navigationController: UINavigationController = {
        
        let nvc = UINavigationController()
        nvc.setNavigationBarHidden(true, animated: false)
        return nvc
    }()
    
    init(window: UIWindow) {
        
        self.window = window
    }
    
    func presentUI(presenter: DecidePresenter) {
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        navigationController.setViewControllers([decideViewController(presenter)], animated: false)
    }
}

extension DecideWireframe {
    
    private func decideViewController(presenter: DecidePresenter) -> UIViewController {
        
        let vc = UIDevice.isPad() ? decideViewController_iPad() : decideViewController_iPhone()
        vc.delegate = presenter
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
