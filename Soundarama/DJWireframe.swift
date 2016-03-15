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
    
    private weak var djViewController : DJViewController!
    
    private weak var navigationController: UINavigationController!
    
    func presentDJUserInterface(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        let vc = UIDevice.isPad() ? djViewController_iPad() : djViewController_iPhone()
        djPresenter.ui = vc
        vc.delegate = djPresenter
        vc.userInterfaceDelegate = djPresenter
        navigationController.pushViewController(vc, animated: true)
        djViewController = vc
    }
    
    func dismissDJUserInterface() {
        
        navigationController.popViewControllerAnimated(true)
    }
    
    func djAudioStemPickerUserInterface() -> DJAudioStemPickerUserInterface  {
        
        return djAudioStemPickerViewController_universal()
    }
    
    func presentAudioStemPickerUserInterface(audioStemPickerUserInterface: DJAudioStemPickerUserInterface) {
        
        let vc = audioStemPickerUserInterface as! UIViewController
        let view = djViewController.view
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.sourceRect = CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 0, 0)
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.permittedArrowDirections = []
        djViewController.presentViewController(vc, animated: true, completion: nil)
    }
    
    func dismissAudioStemPickerUserInterface(audioStemPickerUserInterface: DJAudioStemPickerUserInterface) {
        
        let vc = audioStemPickerUserInterface as! UIViewController
        vc.dismissViewControllerAnimated(true, completion: nil)
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
    
    private func djAudioStemPickerViewController_universal() -> DJAudioStemPickerViewController {
     
        let sb = UIStoryboard(name: "DJStoryboard", bundle: nil)
        return sb.instantiateViewControllerWithIdentifier("DJAudioStemPickerViewController") as! DJAudioStemPickerViewController
    }
}
