//
//  PerformerWireframe.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class PerformerWireframe {
    
    weak var performerPresenter: PerformerPresenter!
    
    func presentPerformerUI(navigationController: UINavigationController) {
        
        if navigationController.viewControllers.count > 0 {
            navigationController.pushViewController(performerViewController(), animated: true)
        } else {
            navigationController.viewControllers = [performerViewController()]
        }
    }
    
    func performerViewController() -> UIViewController {
        
        let sb = UIStoryboard(name: "PerformerStoryboard", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("PerformerViewController") as! PerformerViewController
        performerPresenter.ui = vc
        vc.delegate = performerPresenter
        return vc
    }
}
