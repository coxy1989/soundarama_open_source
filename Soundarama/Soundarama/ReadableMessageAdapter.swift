//
//  SubscriberMessageAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//


protocol ReadableMessageAdapterDelegate: class {
    
    func didReceiveAudioStemMessage(message: AudioStemMessage)
    
    func didRecieveVolumeChangeMessage(message: VolumeChangeMessage)
}

class ReadableMessageAdapter {
    
    var delegate: ReadableMessageAdapterDelegate!
    
    private let readable: Readable
    
    init(readable: Readable) {
        
        self.readable = readable
        self.readable.readableDelegate = self
    }
    
    func takeMessage() {
        
        readable.readData(Serialisation.terminator)
    }
}

extension ReadableMessageAdapter: ReadableDelegate {
    
    func didReadData(data: NSData) {
    
        if let audioStemMessage = audioStemMessage(data) {
            delegate.didReceiveAudioStemMessage(audioStemMessage)
        }
    }
}

extension ReadableMessageAdapter {
    
    func audioStemMessage(data: NSData) -> AudioStemMessage? {
        
        let pl = Serialisation.getPayload(data)
        if let msg = NSKeyedUnarchiver.unarchiveObjectWithData(pl) {
            if let  audioStemRef = msg["ref"] as? String,
                timestamp = msg["time"] as? Double,
                loopLength = msg["loopLength"] as? NSTimeInterval,
               // typeVal = msg["type"] as? UInt,
                sessionStamp = msg["sessionTimestamp"] as? Double {
                return AudioStemMessage(audioStemRef: audioStemRef, timestamp: timestamp, sessionTimestamp: sessionStamp, loopLength: loopLength, type: .Start)
                    
            } else {
                return nil
            }
        }
        else {
            return nil
        }
    }
}
