//
//  StateMessageDeserializerTests.swift
//  Soundarama
//
//  Created by Jamie Cox on 27/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import XCTest
@testable import Soundarama

class StateMesssageDeserializerTests: XCTestCase {}


extension StateMesssageDeserializerTests {
    
    func test_deserialize() {
        
        
        let workspace = Workspace(identifier: "", audioStem: "", performers: Set([""]), isMuted: true, isSolo: true, isAntiSolo: true)
        
        let msg = StateMessage(suite: Set([workspace]), performer: "", referenceTimestamps: [ : ], timestamp: 3)
        
        let dic = StateMessageSerializer.serialize(msg)
        
        let data = try! NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions(rawValue: 0)).mutableCopy()
        
        data.appendData(Serialisation.terminator)
        let range = NSMakeRange(data.length - Serialisation.terminator.length, Serialisation.terminator.length)
        
        data.replaceBytesInRange(range, withBytes: nil, length: 0)
        
        let dic2 = try! NSJSONSerialization.JSONObjectWithData(data as! NSData, options: NSJSONReadingOptions.AllowFragments)
        
        debugPrint(dic2)
        assert(dic == dic2 as! [String : String])
        
        //data.appendData(Serialisation.terminator)
        
        //let payload = Serialisation.getPayload(data as! NSData)
        
        
        
        //let workspace = [ WorkspaceSerialisationKeys.identifier : "7200767C-2D72-4BC7-9E60-9F2AC4C50AC1", WorkspaceSerialisationKeys.audioStem : "SOME", WorkspaceSerialisationKeys.performers : ["some", "some"], WorkspaceSerialisationKeys.muted : true, WorkspaceSerialisationKeys.solo : true, WorkspaceSerialisationKeys.antiSolo : true]
        
        
    /*
        
        let dat = StateMessageSerializer.serialize(msg)
        
        let deser = StateMessageDeserializer.deserialize(dat)
        
        switch deser {
            
            case .Success(let m):
            
                debugPrint(m)
                XCTAssert(true)
            
            case .Failure(let e):
            
                debugPrint(e)
                XCTAssert(false)
        }
 */
    }
    /*
     
        
        //let suite = [["identifier": "7200767C-2D72-4BC7-9E60-9F2AC4C50AC1"], ["identifier": "5A0B8BDF-87A3-42E8-A105-2EFAEB56E563"]]
        
        let suite = [workspace]
        
        let performer = "SOME"
        
        let referenceStamps = [ "" :  434343.43434 ]
        
        let timestamp = 434343443
        
        let json = [ StateMessageSerialisationKeys.suite : suite,
                     StateMessageSerialisationKeys.performer : performer,
                     StateMessageSerialisationKeys.referenceTimestamps : referenceStamps,
                     StateMessageSerialisationKeys.timestamp : timestamp ]
        
        let data = Serialisation.setPayload(json)
        
        let result = StateMessageDeserializer.deserialize(data)
        
        switch result {
            
            case .Success(let m):
                debugPrint(m)
                XCTAssertTrue(true)
            
            case .Failure(let e):
                debugPrint(e)
                XCTAssertFalse(true)
        }
    }
 */
}

