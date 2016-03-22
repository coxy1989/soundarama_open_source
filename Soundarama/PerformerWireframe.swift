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
        
        navigationController.pushViewController(instrumentsViewController(), animated: true)
    }
}

extension PerformerWireframe {
    
    private func instrumentsViewController() -> InstrumentsViewController {
        
        let sb = UIStoryboard(name: "PerformerStoryboard", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("InstrumentsViewController") as! InstrumentsViewController
        vc.userInterfaceDelegate = performerPresenter
        performerPresenter.compassUI = vc
        performerPresenter.levelUI = vc
        performerPresenter.coloredUI = vc
        performerPresenter.connectionUI = vc
        return vc
    }
}
