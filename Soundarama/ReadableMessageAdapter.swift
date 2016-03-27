//
//  SubscriberMessageAdapter.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

protocol ReadableMessageAdapterDelegate: class {
    
   // func didReceivePerformerMessage(performerMessage: PerformerMessage)

    func didReceiveStartMessage(startMessage: StartMessage)
    
    func didReceiveStopMessage(stopMessage: StopMessage)
    
    func didReceiveMuteMessage()
    
    func didReceiveUnmuteMessage()
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
        if let message = deserialize(data) {
            
            print("Success: Deserialised a message: \(message)")
            delegate.didReceivePerformerMessage(message)
        }
        readable.readData(Serialisation.terminator)
 */
    }
}

extension ReadableMessageAdapter {
    
    func deserialize(data: NSData) {
        
    }
}

/*
extension ReadableMessageAdapter {
    
    func deserialize(data: NSData) -> PerformerMessage? {
        
        let payload = Serialisation.getPayload(data)
        
        guard let json = NSKeyedUnarchiver.unarchiveObjectWithData(payload) else {
            
            print("Failed to unarchive JSON")
            return nil
        }
        
        guard let timestamp = json["timestamp"] as? Double,
            sessionTimestamp = json["sessionTimestamp"] as? Double,
            reference = json["reference"] as? String,
            loopLength = json["loopLength"] as? Double,
            commandRaw = json["command"] as? UInt,
            command = PerformerMessageCommand(rawValue:commandRaw),
            muted = json["muted"] as? Bool
            
        else {
            print("Failed to deserialise JSON")
            return nil
        }
        
        return PerformerMessage(address: "X", timestamp: timestamp, sessionTimestamp: sessionTimestamp, reference: reference, loopLength: loopLength, command: command, muted: muted)
    }
}
*/