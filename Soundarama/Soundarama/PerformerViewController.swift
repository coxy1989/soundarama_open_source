//
//  PerformerViewController.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class PerformerViewController: UIViewController, PerformerUserInterface {
    
    weak var delegate: PerformerUserInterfaceDelegate!
    
    struct Strings {
        
        static let Connected = "Connecté"
        static let NotConnected = "Non Connecté"
    }
    
    static let timestamp = NSDate().timeIntervalSince1970
    
    @IBOutlet weak var imageView: UIImageView?
    
    @IBOutlet weak var label: UILabel?
    
    override func viewDidLoad() {
        
        delegate.ready()
    }
    
    func setConnectionState(state: ConnectionState) {
        
        if state == .Connected {
            label?.text = Strings.Connected
        } else if state == .NotConnected {
            label?.text = Strings.NotConnected
        }
    }
    
    func setAudioStem(audioStem: AudioStem) {
        
        view.backgroundColor = audioStem.colour
        label?.textColor = audioStem.colour
    }
}
