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
    
    func djUserInterface() -> DJUserInterface {
        
        let vc = UIDevice.isPad() ? djViewController_iPad() : djViewController_iPhone()
        djPresenter.ui = vc
        vc.delegate = djPresenter
        return vc
    }
}

extension DJWireframe {
    
    private func djViewController_iPhone() -> DJViewController {
        
        let sb = UIStoryboard(name: "DJStoryboard", bundle: nil)
        return sb.instantiateViewControllerWithIdentifier("DJViewController_iPhone") as! DJViewController
    }
    
    private func djViewController_iPad() -> DJViewController {
        
        let sb = UIStoryboard(name: "DJStoryboard", bundle: nil)
        return sb.instantiateViewControllerWithIdentifier("DJViewController_iPad") as! DJViewController
    }
}

    /*
    func presentDjUI(navigationController: UINavigationController) {
        self.navigationController = navigationController
        let vc = djViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    
    func unpresentDJUI() {
        
        navigationController.popViewControllerAnimated(true)
    }
*/