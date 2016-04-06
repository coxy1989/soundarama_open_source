//
//  PerformerWireframe.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class PerformerWireframe {
    
    private static let sb = UIStoryboard(name: "PerformerStoryboard", bundle: nil)
    
    private var instrumentsVC: InstrumentsViewController!
    
    private var djPickerVC: PickDJViewController?
    
    weak var performerPresenter: PerformerPresenter!
    
    weak var navigationController: UINavigationController?
    
    func presentDJPickerUI() {
        
        let vc = UIDevice.isPad() ? PerformerWireframe.pickDJViewController_iPad(performerPresenter) : PerformerWireframe.pickDJViewController_iPhone(performerPresenter)
        let view = instrumentsVC.view
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.sourceRect = CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 0, 0)
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.permittedArrowDirections = []
        instrumentsVC.presentViewController(vc, animated: true, completion: nil)
        djPickerVC = vc
    }
    
    func dismissDJPickerUI() {
        
        djPickerVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentInstrumentsUI(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        instrumentsVC = PerformerWireframe.instrumentsViewController(performerPresenter)
        instrumentsVC.connectionUserInterfaceDelegate = performerPresenter
        navigationController.pushViewController(instrumentsVC!, animated: true)
    }
    
    func dismissInstrumentsUI() {
        
        navigationController?.popViewControllerAnimated(true)
        
    }
}

extension PerformerWireframe {
    
    private static func instrumentsViewController(performerPresenter: PerformerPresenter) -> InstrumentsViewController {
        
        let vc = sb.instantiateViewControllerWithIdentifier("InstrumentsViewController") as! InstrumentsViewController
        vc.userInterfaceDelegate = performerPresenter
        performerPresenter.compassUI = vc
        performerPresenter.levelUI = vc
        performerPresenter.coloredUI = vc
        performerPresenter.connectionUI = vc
        return vc
    }
    
    private static func pickDJViewController_iPad(performerPresenter: PerformerPresenter) -> PickDJViewController {
     
        let vc = sb.instantiateViewControllerWithIdentifier("PickDJViewController") as! PickDJViewController
        vc.delegate = performerPresenter
        vc.userInterfaceDelegate = performerPresenter
        performerPresenter.pickDJUI = vc
        return vc
    }
    
    private static func pickDJViewController_iPhone(performerPresenter: PerformerPresenter) -> PickDJViewController {
        
        let vc = sb.instantiateViewControllerWithIdentifier("PickDJViewController_iPhone") as! PickDJViewController
        vc.delegate = performerPresenter
        vc.userInterfaceDelegate = performerPresenter
        performerPresenter.pickDJUI = vc
        return vc
    }
}
