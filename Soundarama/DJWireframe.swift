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
    
    private let storyboard = UIStoryboard(name: "DJStoryboard", bundle: nil)
    
    private weak var djViewController : DJViewController!
    
    private weak var navigationController: UINavigationController!
    
    func presentDJUserInterface(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
        let vc = UIDevice.isPad() ? djViewController_iPad() : djViewController_iPhone()
        djPresenter.djUI = vc
        vc.delegate = djPresenter
        vc.userInterfaceDelegate = djPresenter
        navigationController.pushViewController(vc, animated: true)
        djViewController = vc
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
    
    func presentBroadcastConfigurationUserInterface() {
        
        let vc = djBroadcastConfigurationViewController()
        vc.userInterfaceDelegate = djPresenter
        vc.delegate = djPresenter
        djPresenter.djBroadcastConfigurationUI = vc
        let view = djViewController.view
        vc.modalPresentationStyle = .Popover
        vc.popoverPresentationController?.sourceRect = CGRectMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds), 0, 0)
        vc.popoverPresentationController?.sourceView = view
        vc.popoverPresentationController?.permittedArrowDirections = []
        djViewController.presentViewController(vc, animated: true, completion: nil)
    }
    
    func dismissDJUserInterface() {
        
        navigationController.popViewControllerAnimated(true)
    }
    
    func dismissAudioStemPickerUserInterface(audioStemPickerUserInterface: DJAudioStemPickerUserInterface) {
        
        let vc = audioStemPickerUserInterface as! UIViewController
        vc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissBroadcastConfigurationUserInterface(broadcastConfigurationUserInterface: DJBroadcastConfigurationUserInterface) {
        
        let vc = broadcastConfigurationUserInterface as! UIViewController
        vc.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func djAudioStemPickerUserInterface() -> DJAudioStemPickerUserInterface  {
        
        let vc = UIDevice.isPad() ? djAudioStemPickerViewController_iPad() : djAudioStemPickerViewController_iPhone()
        vc.delegate = djPresenter
        djPresenter.djAudioStemPickerUI = vc
        vc.userInterfaceDelegate = djPresenter
        return vc
    }
}

extension DJWireframe {
    
    private func djViewController_iPhone() -> DJViewController {
        
        return storyboard.instantiateViewControllerWithIdentifier("DJViewController_iPhone") as! DJViewController
    }
    
    private func djViewController_iPad() -> DJViewController {
        
        return storyboard.instantiateViewControllerWithIdentifier("DJViewController_iPad") as! DJViewController
    }
    
    private func djAudioStemPickerViewController_iPhone() -> DJAudioStemPickerViewController {
     
        return storyboard.instantiateViewControllerWithIdentifier("DJAudioStemPickerViewController_iPhone") as! DJAudioStemPickerViewController
    }
    
    private func djAudioStemPickerViewController_iPad() -> DJAudioStemPickerViewController {
        
        return storyboard.instantiateViewControllerWithIdentifier("DJAudioStemPickerViewController_iPad") as! DJAudioStemPickerViewController
    }
    
    private func djBroadcastConfigurationViewController() -> DJBroadcastConfigurationViewController {
        
        return storyboard.instantiateViewControllerWithIdentifier("DJBroadcastConfigurationViewController") as! DJBroadcastConfigurationViewController
    }
}
