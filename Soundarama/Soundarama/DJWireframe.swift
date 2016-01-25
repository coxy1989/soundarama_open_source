//
//  DJWireframe.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJWireframe {
    
    weak var djPresenter: DJPresenter!
    
    func presentDjUI(navigationController: UINavigationController) {
        
        let vc = djViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func djViewController() -> UIViewController {
        
        let sb = UIStoryboard(name: "DJStoryboard", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("DJViewController") as! DJViewController
        djPresenter.ui = vc
        vc.delegate = djPresenter
        return vc
    }
}
