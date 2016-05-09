//
//  InstrumentsViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit
import TouchpressUI

class InstrumentsViewController: ViewController, PerformerUserInterface {
    
    @IBOutlet private weak var topLabel: UILabel!
    
    @IBOutlet private weak var compassView: CompassView?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var infoButton: UIButton!
    
    @IBAction func didPressInfoButton(sender: AnyObject) { requestOnboarding?() }
    
    @IBAction private func didPressBackButton(sender: AnyObject) {
        
        userInterfaceDelegate?.userInterfaceDidNavigateBack(self)
    }
    
    var requestOnboarding: (() -> ())?
    
    private lazy var backgroundGradientLayer: CAGradientLayer = {
        
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0, y: 0)
        l.endPoint = CGPoint(x: 0, y: 1)
        return l
    }()
    
    private lazy var mutedOverlayView: UIView = {
        
        let v = NSBundle.mainBundle().loadNibNamed("MutedView", owner: self, options: nil).first as! MutedView
        v.userInteractionEnabled = false
        v.label.text = "PERFORMER_MUTED".localizedString
        return v
    }()
    
    private let chargeGradientView = ChargeGradientView()
    
    private let chargeLevelView = ChargeLevelView()
    
    private var instructionView: InstructionView?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        view.layer.insertSublayer(backgroundGradientLayer, atIndex: 0)
        compassView?.addSubview(chargeGradientView)
        compassView!.addSubview(chargeLevelView)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    
        setCharge(0)
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        backgroundGradientLayer.frame = view.bounds
        
        let size = compassView!.intrinsicContentSize()
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        chargeLevelView.frame = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(0.7, 0.7))
        chargeLevelView.center = CGPointMake(CGRectGetMidX(compassView!.bounds), CGRectGetMidY(compassView!.bounds))
    }
    
    func setChargeGradientViewScale(scale: CGFloat) {
        
        let size = compassView!.intrinsicContentSize()
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        chargeGradientView.frame = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(scale, scale))
        chargeGradientView.center = CGPointMake(CGRectGetMidX(compassView!.bounds), CGRectGetMidY(compassView!.bounds))
    }
}

extension InstrumentsViewController: MutedUserInterface {
    
    func setMuted(value: Bool) {
        
        mutedOverlayView.removeFromSuperview()
        
        if value {
            
            mutedOverlayView.frame = view.bounds
            view.addSubview(mutedOverlayView)
        }
    }
}

extension InstrumentsViewController: PerformerInstructionUserInterface {
    
    func showInstruction(instruction: PerformerInstruction) {
        
        instructionView = newInstructionView()
        view.addSubview(instructionView!)
        presentInstructionView(instructionView!)
        
        switch instruction {
            
            case .ChargingInstruction:
            
                instructionView?.titleLabel.text = "PERFORMER_DANCEOMETER_ONBOARDING_HEADER".localizedString
                instructionView?.messageLabel.text = "PERFORMER_DANCEOMETER_ONBOARDING_BODY".localizedString
            
            case .CompassInstruction:
            
                instructionView?.titleLabel.text = "PERFORMER_COMPASS_ONBOARDING_HEADER".localizedString
                instructionView?.messageLabel.text = "PERFORMER_COMPASS_ONBOARDING_BODY".localizedString
        }
    }
    
    func hideInstruction() {
        
        let _ = instructionView.map(dismissInstructionView)
    }
}

extension InstrumentsViewController: CurrentlyPerformingUserInterface {
    
    func setCurrentlyPerforming(name: String?) {
        
        guard let name = name else {
            
            topLabel.text = "PERFORMER_WAITING_FOR_SOUND".localizedString
            chargeLevelView.hidden = true
            chargeGradientView.hidden = true
            compassView?.setPointsHidden(true)
            return
        }
    
        chargeLevelView.hidden = false
        chargeGradientView.hidden = false
        compassView?.setPointsHidden(false)
        
        let s = NSMutableAttributedString(string: "PERFORMER_CURRENTLY_PERFORMING".localizedString + "\n", attributes: UIFont.fontAttribute(UIFont.avenirLight(16)))
        s.appendAttributedString(NSMutableAttributedString(string: name, attributes: UIFont.fontAttribute(UIFont.avenirHeavy(16))))
        topLabel.attributedText = s
    }
}

extension InstrumentsViewController: ColoredUserInteface {
    
    func setColors(colors: [UIColor]) {
        
        backgroundGradientLayer.colors = [colors[1], colors[2] ].map() { $0.CGColor }
        chargeGradientView.setColors(colors)
        compassView?.setColors(colors)
        chargeLevelView.setColors(colors)
    }
}

extension InstrumentsViewController: ChargingUserInteface {
 
    func setCharge(value: Double) {
        
        UIView.animateWithDuration(0.1) { [weak self] in
            
            if value >= 0.7 {
                self?.chargeLevelView.setOverColor()
                self?.chargeGradientView.alpha = 0.8
            }
            else {
                self?.chargeLevelView.setUnderColor()
                self?.chargeGradientView.alpha = 0.4
            }
            self?.setChargeGradientViewScale(CGFloat(value))
        }
    }
}

extension InstrumentsViewController: CompassUserInterface {
    
    func setCompassValue(value: Double) {
        
        let radians = CGFloat((M_PI * value) / 180)
        
        UIView.animateWithDuration(0.1) { [weak self] in
        
            self?.compassView?.transform = CGAffineTransformMakeRotation(-radians)
        }
    }
}

extension InstrumentsViewController {
    
    func newInstructionView() -> InstructionView {
        
        let v =  NSBundle.mainBundle().loadNibNamed("InstructionView", owner: self, options: nil).first as! InstructionView
        v.frame = CGRectMake(0, view.bounds.size.height, view.bounds.size.width, 127)
        return v
    }
    
    func presentInstructionView(instructionView: UIView) {
        
        let post = CGRectApplyAffineTransform(instructionView.frame, CGAffineTransformMakeTranslation(0, -instructionView.bounds.height))
        
        UIView.animateWithDuration(0.5) {
            
            instructionView.frame = post
        }
    }
    
    func dismissInstructionView(instructionView: UIView) {
        
        let pre = CGRectMake(0, view.bounds.size.height, view.bounds.size.width, 127)
        
        UIView.animateWithDuration(0.5) {
            
            instructionView.frame = pre
        }
    }
}

extension InstrumentsViewController: ReconnectionUserInterface {
    
    func updateWithReconnectionEvent(event: ReconnectionEvent) {
        
        switch event {
            
            case .Started:
                
                let s = NSMutableAttributedString(string: "PERFORMER_LOST_CONNECTION_HEADER".localizedString + "\n", attributes: UIFont.fontAttribute(UIFont.avenirLight(16)))
                
                s.appendAttributedString(NSMutableAttributedString(string: "PERFORMER_ATTEMPT_RECONNECT_BODY".localizedString, attributes: UIFont.fontAttribute(UIFont.avenirHeavy(16))))
                
                topLabel.attributedText = s
            
                activityIndicator.hidden = false
                activityIndicator.startAnimating()
            
            case .EndedFailure:
            
                topLabel.text = "PERFORMER_RECONNECT_FAILED".localizedString
                
                activityIndicator.hidden = true
                activityIndicator.stopAnimating()
            
            case .EndedSucceess:
                
                topLabel.text = "PERFORMER_WAITING_FOR_SOUND".localizedString
            
                activityIndicator.hidden = true
                activityIndicator.stopAnimating()
        }
    }
}
