//
//  SubscriberMessageAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol ReadableMessageAdapterDelegate: class {
    
   // func didReceiveAudioStemMessage(message: AudioStemMessage)

}

class ReadableMessageAdapter {
    
    var delegate: ReadableMessageAdapterDelegate!
    
    private let readable: Readable
    
    init(readable: Readable) {
        
        self.readable = readable
        self.readable.readableDelegate = self
    }
    
    func takeMessages() {
        
        readable.readData(Serialisation.terminator)
    }
}

extension ReadableMessageAdapter: ReadableDelegate {
    
    func didReadData(data: NSData, address: Address) {
    
        /*
        if let audioStemMessage = audioStemMessage(data) {
            delegate.didReceiveAudioStemMessage(audioStemMessage)
        }
        */
        readable.readData(Serialisation.terminator)
    }
}

extension ReadableMessageAdapter {
    
    /*
    func audioStemMessage(data: NSData) -> AudioStemMessage? {
        
        let pl = Serialisation.getPayload(data)
        if let msg = NSKeyedUnarchiver.unarchiveObjectWithData(pl) {
            if let ref = msg["ref"] as? String,
                timestamp = msg["time"] as? Double,
                sessionStamp = msg["sessionTimestamp"] as? Double,
                loopLength = msg["loopLength"] as? NSTimeInterval,
                typeValue = msg["type"] as? UInt,
                t = AudioStemMessage.MessageType(rawValue: typeValue) {
                    return AudioStemMessage(reference: ref, timestamp: timestamp, sessionTimestamp: sessionStamp, loopLength: loopLength, type: t)
                    
            } else {
                return nil
            }
        }
        else {
            return nil
        }
    }
*/
}
