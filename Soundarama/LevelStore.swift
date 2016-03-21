//
//  LevelStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class LevelStore {
    
    private var level: Level = .Middle
    private var locked = false
    
    func getLevel() -> Level {
        
        return level
    }
    
    func setLevel(level: Level) {
        
        guard !locked else {
            
            return
        }
        
        self.level = level
    }
    
    func unlock() {
        
        locked = false
    }
    
    func lock() {
        
        locked = true
    }
}

