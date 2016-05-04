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
    
    private let chargeGradientView = ChargeGradientView()
    
    private let chargeLevelView = ChargeLevelView()
    
    private var instructionView: InstructionView?
    
    //TODO: Lose this!
    var dirtyCalibrated = false

    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        view.layer.insertSublayer(backgroundGradientLayer, below: compassView!.layer)
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
        
        chargeLevelView.frame = CGRectApplyAffineTransform(compassView!.bounds, CGAffineTransformMakeScale(0.7, 0.7))
        chargeLevelView.center = CGPointMake(CGRectGetMidX(compassView!.bounds), CGRectGetMidY(compassView!.bounds))
    }
    
    func setChargeGradientViewScale(scale: CGFloat) {
        
        chargeGradientView.frame = CGRectApplyAffineTransform(compassView!.bounds, CGAffineTransformMakeScale(scale, scale))
        chargeGradientView.center = CGPointMake(CGRectGetMidX(compassView!.bounds), CGRectGetMidY(compassView!.bounds))
    }
}

extension InstrumentsViewController {
    
    func startFlashing() {
        
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

extension InstrumentsViewController /*: PerformerInstructionUserInterface */ {
    
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

extension InstrumentsViewController /*: CurrentlyPerformingUserInterface */ {
    
    func setCurrentlyPerforming(name: String?) {
        
        guard let name = name else {
            
            topLabel.text = "Waiting for the conductor \n to send you a sound..."
            return
        }
        
        let avenir_light = UIFont .customFontWithName("Avenir-Light", size: 16)
        let avenir_light_map = [NSFontAttributeName : avenir_light]
        let part_1 = NSMutableAttributedString(string: "Currently performing:\n", attributes: avenir_light_map)
        
        let avenir_heavy = UIFont .customFontWithName("Avenir-Heavy", size: 16)
        let avenir_heavy_map = [NSFontAttributeName : avenir_heavy]
        let part_2 = NSMutableAttributedString(string: name, attributes: avenir_heavy_map)
        
        part_1.appendAttributedString(part_2)
        
        topLabel.attributedText = part_1
    }
}

extension InstrumentsViewController /*: ColoredUserInteface */ {
    
    func setColors(colors: [UIColor]) {
        
        backgroundGradientLayer.colors = [colors[1], colors[2] ].map() { $0.CGColor }
        chargeGradientView.setColors(colors)
        compassView?.setColors(colors)
        chargeLevelView.setColors(colors)
    }
}

extension InstrumentsViewController /*: ChargingUserInteface */ {
 
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
        
        guard dirtyCalibrated == true else {
            
            compassView?.transform = CGAffineTransformMakeRotation(-radians)
            dirtyCalibrated = true
            return
        }
        
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

extension InstrumentsViewController /* : ReconnectionUserInterface */ {
    
    func updateWithReconnectionEvent(event: ReconnectionEvent) {
        
        /*
        switch event {
            
            case .Started: reconnectionLabel.hidden = false
            
            case .EndedFailure: reconnectionLabel.text = "Failed to reconnect"
            
            case .EndedSucceess: reconnectionLabel.hidden = true
        }
 */
    }
}
