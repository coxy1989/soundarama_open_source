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

    @IBOutlet weak var turnIcon: UIImageView!
    
    @IBOutlet weak var turnLabel: UILabel!
    
    @IBOutlet weak var danceIcon: UIImageView!
    
    @IBOutlet weak var danceLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction private func turnIconWasTapped(sender: AnyObject) {
    
        requestShowInstruction?(.CompassInstruction)
    }
    
    @IBAction private func danceIconWasTapped(sender: AnyObject) {
        
        requestShowInstruction?(.ChargingInstruction)
    }
    
    @IBAction private func didPressBackButton(sender: AnyObject) {
        
        userInterfaceDelegate?.userInterfaceDidNavigateBack(self)
    }
    
    var requestShowInstruction: ((PerformerInstruction) -> ())?
    
    var requestHideInstruction: ((PerformerInstruction) -> ())?
    
    private lazy var backgroundGradientLayer: CAGradientLayer = {
        
        let l = CAGradientLayer()
        l.startPoint = CGPoint(x: 0, y: 0)
        l.endPoint = CGPoint(x: 0, y: 1)
        return l
    }()
    
    private lazy var flashingOverlayView: UIView = {
        
        let v = UIView()
        v.backgroundColor = UIColor.whiteColor()
        v.alpha = 0
        v.userInteractionEnabled = false
        return v
    }()
    
    private lazy var mutedOverlayView: UIView = {
        
        let v = NSBundle.mainBundle().loadNibNamed("MutedView", owner: self, options: nil).first as! UIView
        v.userInteractionEnabled = false
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

extension InstrumentsViewController: FlashingUserinterface {
    
    func startFlashing() {
        
        flashingOverlayView.removeFromSuperview()
        flashingOverlayView.frame = view.bounds
        view.addSubview(flashingOverlayView)
    }
    
    func stopFlashing() {
        
        flashingOverlayView.removeFromSuperview()
    }
    
    func flash(opacity: CGFloat, duration: NSTimeInterval) {
        
        UIView.animateWithDuration(duration) { [weak self] in
            
            self?.flashingOverlayView.alpha = opacity
        }
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
        instructionView!.dismissAction = { [weak self] in self?.requestHideInstruction?(instruction) }
        view.addSubview(instructionView!)
        presentInstructionView(instructionView!)
        
        switch instruction {
            
            case .ChargingInstruction:
            
                instructionView?.titleLabel.text = "Move around!"
                instructionView?.messageLabel.text = "Move around to unlock added sounds"
            
            case .CompassInstruction:
            
                instructionView?.titleLabel.text = "Turn on the spot"
                instructionView?.messageLabel.text = "Turn on the spot to change your sound"
        }
    }
    
    func hideInstruction() {
        
        let _ = instructionView.map(dismissInstructionView)
    }
}

extension InstrumentsViewController: CurrentlyPerformingUserInterface {
    
    func setCurrentlyPerforming(name: String?) {
        
        guard let name = name else {
            
            topLabel.text = "Waiting for the conductor \n to send you a sound"
            chargeLevelView.hidden = true
            chargeGradientView.hidden = true
            compassView?.setPointsHidden(true)
            return
        }
    
        chargeLevelView.hidden = false
        chargeGradientView.hidden = false
        compassView?.setPointsHidden(false)
        
        let s = NSMutableAttributedString(string: "Currently performing\n", attributes: UIFont.fontAttribute(UIFont.avenirLight(16)))
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
    
    func setChargeActive(value: Bool) {
        
        UIView.animateWithDuration(0.2) { [weak self] in
            
            let alpha = CGFloat(value ? 1 : 0.4)
            self?.danceIcon.alpha = alpha
            self?.danceLabel.alpha = alpha
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
    
    func setCompassActive(value: Bool) {
        
        UIView.animateWithDuration(0.1) { [weak self] in
            
            let alpha = CGFloat(value ? 1 : 0.4)
            self?.turnIcon.alpha = alpha
            self?.turnLabel.alpha = alpha
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
        
                let s = NSMutableAttributedString(string: "Lost connection to the conductor\n", attributes: UIFont.fontAttribute(UIFont.avenirLight(16)))
                
                s.appendAttributedString(NSMutableAttributedString(string: "Attempting to reconnect", attributes: UIFont.fontAttribute(UIFont.avenirHeavy(16))))
                
                topLabel.attributedText = s
            
                activityIndicator.hidden = false
                activityIndicator.startAnimating()
            
            case .EndedFailure:
            
                topLabel.text = "The conductor became unreachable"
                
                activityIndicator.hidden = true
                activityIndicator.stopAnimating()
            
            case .EndedSucceess:
            
                debugPrint("Successfully reconnected")
                
                topLabel.text = "Waiting for the conductor \n to send you a sound"
            
                activityIndicator.hidden = true
                activityIndicator.stopAnimating()
        }
    }
}
