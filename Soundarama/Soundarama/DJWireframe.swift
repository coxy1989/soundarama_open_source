//
//  DJWireframe.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class DJWireframe {
    
    func presentDjUI(navigationController: UINavigationController) {
        navigationController.pushViewController(djViewController(), animated: true)
    }
    
    private func djViewController() -> UIViewController {
        
        let sb = UIStoryboard(name: "DJStoryboard", bundle: nil)
        return sb.instantiateViewControllerWithIdentifier("DJViewController")
    }
}
