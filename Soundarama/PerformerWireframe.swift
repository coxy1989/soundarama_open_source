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
    
    private var djPickerBackgroundVC: PickDJViewController_iPadBackgroundViewController?
    
    weak var navigationController: UINavigationController!
    
    func presentDJPickerUI(presenter: PerformerPresenter) {
        
        UIDevice.isPad() ? presentDJPickerUI_iPad(navigationController, presenter: presenter) : presentDJPickerUI_iPhone(navigationController, presenter: presenter)
    }
    
    func dismissDJPickerUI() {
        
        navigationController.popViewControllerAnimated(true)
    }
    
    func presentInstrumentsUI(presenter: PerformerPresenter) {
        
        let instrumentsVC = PerformerWireframe.instrumentsViewController(presenter)
        navigationController?.pushViewController(instrumentsVC, animated: true)
    }
    
    func dismissInstrumentsUI(presenter: PerformerPresenter) {
        
        presenter.compassUI = nil
        presenter.coloredUI = nil
        presenter.chargingUI = nil
        presenter.reconnectionUI = nil
        navigationController?.popViewControllerAnimated(true)
    }
}

extension PerformerWireframe {
    
    private func presentDJPickerUI_iPhone(navigationController: UINavigationController, presenter: PerformerPresenter) {
        
        let vc = PerformerWireframe.pickDJViewController_iPhone(presenter)
        
        presenter.pickDJUI = vc
        self.navigationController = navigationController
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func presentDJPickerUI_iPad(navigationController: UINavigationController, presenter: PerformerPresenter) {
        
        let rvc = PerformerWireframe.pickDJViewController_iPadBackgroundViewController()
        djPickerBackgroundVC = rvc
        self.navigationController = navigationController
        navigationController.pushViewController(rvc, animated: true)
        rvc.onEmbeddedPickDJViewController = {
            
            presenter.pickDJUI = $0
            $0.delegate = presenter
            $0.userInterfaceDelegate = presenter
        }
    }
}

extension PerformerWireframe {
    
    private static func instrumentsViewController(performerPresenter: PerformerPresenter) -> InstrumentsViewController {
        
        let vc = sb.instantiateViewControllerWithIdentifier("InstrumentsViewController") as! InstrumentsViewController
        vc.userInterfaceDelegate = performerPresenter
        performerPresenter.compassUI = vc
        performerPresenter.coloredUI = vc
        performerPresenter.chargingUI = vc
        performerPresenter.reconnectionUI = vc
        return vc
    }
    
    private static func pickDJViewController_iPhone(performerPresenter: PerformerPresenter) -> PickDJViewController {
        
        let vc = sb.instantiateViewControllerWithIdentifier("PickDJViewController_iPhone") as! PickDJViewController
        vc.delegate = performerPresenter
        vc.userInterfaceDelegate = performerPresenter
        performerPresenter.pickDJUI = vc
        return vc
    }
    
    private static func pickDJViewController_iPadBackgroundViewController() -> PickDJViewController_iPadBackgroundViewController {
        
        return sb.instantiateViewControllerWithIdentifier("PickDJViewController_iPadBackgroundViewController") as! PickDJViewController_iPadBackgroundViewController
    }
}
