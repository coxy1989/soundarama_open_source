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
    
    func presentDJPickerUI(navigationController: UINavigationController) {
        
        UIDevice.isPad() ? presentDJPickerUI_iPad(navigationController) : presentDJPickerUI_iPhone(navigationController)
    }
    
    func dismissDJPickerUI() {
        
        navigationController?.popViewControllerAnimated(true)
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
    
    private func presentDJPickerUI_iPhone(navigationController: UINavigationController) {
        
        let vc = PerformerWireframe.pickDJViewController_iPhone(performerPresenter)
        performerPresenter.pickDJUI = vc
        self.navigationController = navigationController
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func presentDJPickerUI_iPad(navigationController: UINavigationController) {
        
        let rvc = PerformerWireframe.robotWarsViewController()
        self.navigationController = navigationController
        navigationController.pushViewController(rvc, animated: true)
        
        let view = rvc.view
        let vc = PerformerWireframe.pickDJViewController_iPad(performerPresenter)
        djPickerVC = vc
        performerPresenter.pickDJUI = vc
        
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.sourceRect = CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 0, 0)
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.permittedArrowDirections = []
        rvc.presentViewController(vc, animated: true, completion: nil)
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
    
    private static func robotWarsViewController() -> UIViewController {
        
        return sb.instantiateViewControllerWithIdentifier("RobotWarsViewController")
    }
}
