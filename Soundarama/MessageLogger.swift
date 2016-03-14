//
//  MessageLogger.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class MessageLogger {
    
    static func log(messages: [PerformerMessage]) {
        
        if messages.count == 0 {
            return
        }
        
        print("-------- Message Log --------")
        for m in messages {
            print(m)
        }
        print("---- End of Message Log ----")
    }
}