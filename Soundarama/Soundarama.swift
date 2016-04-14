//
//  Soundarama.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import UIKit

class Soundarama {
    
    private var decideModule: DecideModule!
    
    private var djModule: DJModule?
   
    private var performerModule: PerformerModule?
    
    static func start(window: UIWindow) -> Soundarama {
        
        let soundarama = Soundarama()
        soundarama.start(window)
        return soundarama
    }
    
    private func start(window: UIWindow) {
        
        decideModule = DecideModule.start(window) { [unowned self] in $0.0 == .DJ ? self.startDJ($0.1) : self.startPerformer($0.1); return }
    }
    
    private func startDJ(navigationController: UINavigationController) {
        
        djModule = DJModule.start(navigationController) { [unowned self] in
            
            self.djModule = nil
        }
    }
    
    private func startPerformer(navigationController: UINavigationController) {
        
        performerModule = PerformerModule.start(navigationController) { [unowned self] in
            
            self.performerModule = nil
        }
    }
}

