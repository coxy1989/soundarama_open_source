//
//  MessageTransformerTests.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import XCTest
@testable import Soundarama

/*
    Terminology: 

        "WS"        : workspace
        "Cold"      : audioStem == nil
        "Empty"     : status of a WS with no performers

*/

class MessageTransformerTests: XCTestCase {
    
    var audioStem: AudioStem!
    var audioStem2: AudioStem!
    
    override func setUp() {
        
        audioStem = AudioStem(name: "x", colour: UIColor.redColor(), category: "y", reference: "z", loopLength: 1.0)
        audioStem2 = AudioStem(name: "a", colour: UIColor.blueColor(), category: "b", reference: "c", loopLength: 2.0)
        super.setUp()
    }
    
    override func tearDown() {
        
        super.tearDown()
        audioStem = nil
        audioStem2 = nil
    }
}

/* Test: The Null Case */

extension MessageTransformerTests {
    
    func testNoChange_emptyColdUnmutedWS() {
        
        /* 
            From:

                [ stem: nil, performers: [], M: 0, S: 0 ]
        
            To:
        
                [ stem: nil, performers: [], M: 0, S: 0 ]
        
        */
        
        let from = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let to = from
        
    
        let res = MessageTransformer.transform(Set([to]), toSuite: Set([from]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [ : ])
        XCTAssertEqual(res.count, 0)
    }
    
    
    func testNoChange_hotOccupiedWS() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        */
        
        let p = "x"
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = MessageTransformer.transform([from_ws1], toSuite: [to_ws1], timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [ : ])
        XCTAssertEqual(res.count, 0)
    }
}


 
/* Test: Added Performer */

extension MessageTransformerTests {
    
    func testAddedPerformer_Cold_Empty_Unmuted_WS() {
        
        /*
        From:
        
            [ stem: nil, performers: [], M: 0, S: 0 ]
        
        To:
        
            [ stem: nil, performers: ["x"], M: 0, S: 0 ]

        */
        
        let id = "A"
        let newPerformer = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: nil, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: nil, performers: Set([newPerformer]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = MessageTransformer.transform([from_ws1], toSuite: [to_ws1], timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [ : ])
        XCTAssertEqual(res.count, 0)
    }
    
    func testAddedPerformer_Hot_Empty_Unmuted_WS() {
    
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        */
        
        let id = "A"
        let newPerformer = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: nil, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([newPerformer]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let result = MessageTransformer.transform([from_ws1], toSuite: [to_ws1], timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem.reference : 2])
        
        let expected = StartMessage(address: "x", timestamp: 0, reference: audioStem.reference, sessionTimestamp: 1, referenceTimestamp: 2, muted: false)
        
        
        XCTAssertTrue(result.first as! StartMessage == expected)
    }
    
    
    func testAddedPerformer_Hot_Empty_Muted_WS() {
        
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 1, S: 0 ]
        
        */
        
        let id = "A"
        let newPerformer = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([newPerformer]), isMuted: true, isSolo: false, isAntiSolo: false)
        let res = MessageTransformer.transform([from_ws1], toSuite: [to_ws1], timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem.reference : 2])
        let msg = res.first as! StartMessage
        
        XCTAssertEqual(res.count, 1)
        XCTAssert(res.count == 1)
        XCTAssertEqual(msg.type, MessageType.Start)
        XCTAssertEqual(msg.address, newPerformer)
        XCTAssertEqual(msg.timestamp, 0)
        XCTAssertEqual(msg.sessionTimestamp, 1)
        XCTAssertEqual(msg.referenceTimestamp, 2)
        XCTAssertEqual(msg.reference, audioStem.reference)
        
        XCTAssertTrue(msg.muted)
    }
    
    
    func testAddedPerformer_Hot_Empty_Unmuted_AntiSolo_WS() {
        
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0, AS: 1 ]
            [ stem: SOME2, performers: [], M: 0, S: 1, AS: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 0, AS: 1 ]
            [ stem: SOME2, performers: [], M: 0, S: 1, AS: 0 ]
        
        */
        
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: true, isAntiSolo: true)
        let from_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set([]), isMuted: false, isSolo: true, isAntiSolo: false)
        
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: true)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(), isMuted: true, isSolo: true, isAntiSolo: false)
        
        let res = MessageTransformer.transform([from_ws1, from_ws2], toSuite: [to_ws1, to_ws2], timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem.reference : 2])
        let msg = res.first as! StartMessage
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(msg.type, MessageType.Start)
        XCTAssertEqual(msg.address, "x")
        XCTAssertEqual(msg.timestamp, 0)
        XCTAssertEqual(msg.sessionTimestamp, 1)
        XCTAssertEqual(msg.referenceTimestamp, 2)
        XCTAssertEqual(msg.reference, audioStem.reference)
        
        XCTAssertTrue(msg.muted)
    }
}

/* Test: Removed Performer */

extension MessageTransformerTests {
    
    func testRemovedPerformer_fromHotUnmutedWS_toNowhere() {
        
        /*
            From:
            
                [ stem: SOME1, performers: ["x"], M: 0, S: 0 ]
        
            To:
                [ stem: SOME1, performers: [], M: 0, S: 0 ]
            
        */
    
        let id = "A"
        let p = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = MessageTransformer.transform([from_ws1], toSuite: [to_ws1], timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem.reference : 2])
        let msg = res.first as! StopMessage
        
        XCTAssertEqual(res.count, 1)
        XCTAssert(msg.type == MessageType.Stop)
        XCTAssertEqual(msg.address, "x")
    }
}


/* Test: Moved Performer */

extension MessageTransformerTests {
    
    func testMovedPerformer_toHotEmptyUnmutedWS_fromHotUnmutedWorkspace() {
    
        /*
        From:
        
            [ stem: SOME1, performers: ["x"], M: 0, S: 0 ]
            [ stem: SOME2, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME1, performers: [], M: 0, S: 0 ]
            [ stem: SOME2, performers: ["x"], M: 0, S: 0 ]
        
        */
        
        let id1 = "A"
        let id2 = "B"
        let p = "x"
        
        let from_ws1 = Workspace(identifier: id1, audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let from_ws2 = Workspace(identifier: id2, audioStem: audioStem2, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite1 = Set([from_ws1, from_ws2])
        
        let to_ws1 = Workspace(identifier: id1, audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: id2, audioStem: audioStem2, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite2 = Set([to_ws1, to_ws2])
        
        let res = MessageTransformer.transform(suite1, toSuite: suite2,timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 1)
        
        let msg = res.first as! StartMessage
        XCTAssertTrue(msg.reference == audioStem2.reference)
        XCTAssertTrue(msg.type == .Start)
        
    }
    
    func testMovedPerformer_toHotOccupiedUnmutedWS_fromHotUnmutedWorkspace() {
    
        /*
        From:
        
            [ stem: SOME1, performers: ["x"], M: 0, S: 0 ]
            [ stem: SOME2, performers: ["y"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME1, performers: [], M: 0, S: 0 ]
            [ stem: SOME2, performers: ["y", "x"], M: 0, S: 0 ]
        
        */
        
        let pa = "y"
        let pb = "x"
        
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([pa]), isMuted: false, isSolo: false, isAntiSolo: false)
        let from_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set([pb]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite1 = Set([from_ws1, from_ws2])
        
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set([pb, pa]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite2 = Set([to_ws1, to_ws2])
        
        let res = MessageTransformer.transform(suite1, toSuite: suite2, timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 1)
        
        let msg = res.first as! StartMessage
        XCTAssertEqual(msg.address, pa)
        XCTAssertFalse(msg.muted)
        XCTAssertEqual(msg.reference, audioStem2.reference)
        XCTAssert(msg.type == .Start)
    }
}


/* Test: Changed AudioStem */

extension MessageTransformerTests {
    
    func testSetAudioStem_noPerformersColdToHot() {
    
        /*
        From:
        
            [ stem: nil, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 0)
    }
    
    func testSetAudioStem_noPerformersHotToCold() {
    
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: nil, performers: [], M: 0, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 0)
    }
    
    func testSetAudioStem_noPerformersHotToHot() {
    
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME2, performers: [], M: 0, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem2, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])

        XCTAssertEqual(res.count, 0)
    }
    
    func testSetAudioStem_onePerformerColdToHot() {
    
        /*
        From:
        
            [ stem: nil, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        */
        
        let p = "x"
        
        let from_ws = Workspace(identifier: "A", audioStem: nil, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem.reference : 2])
        XCTAssertEqual(res.count, 1)
        let msg = res.first as! StartMessage
        XCTAssertEqual(msg.address, p)
        XCTAssertFalse(msg.muted)
        XCTAssertEqual(msg.reference, audioStem.reference)
        XCTAssert(msg.type == .Start)
    
    }
    
    func testSetAudioStem_onePerformerHotToCold() {
    
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: nil, performers: ["x"], M: 0, S: 0 ]
        
        */
        
        let p = "x"
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: nil, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem.reference : 2])
        XCTAssertEqual(res.count, 1)
        let msg = res.first as! StopMessage
        XCTAssertEqual(msg.address, p)
        XCTAssert(msg.type == .Stop)

    }
    
    func testSetAudioStem_onePerformerHotToHot() {
    
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME2, performers: ["x"], M: 0, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 1)
        let m = res.first as! StartMessage
        XCTAssertEqual(m.reference, audioStem2.reference)
    }

    func testSetAudioStem_manyPerformersColdToHot() {
    
        /*
        From:
        
            [ stem: nil, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        */
        
        let ps = ["x", "y", "z"]
        
        let from_ws = Workspace(identifier: "A", audioStem: nil, performers: Set(ps), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(ps), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem.reference : 2])
        XCTAssertEqual(res.count, 3)
        XCTAssertEqual(res.filter({ $0.address == "x"}).count, 1)
        XCTAssertEqual(res.filter({ $0.address == "y"}).count, 1)
        XCTAssertEqual(res.filter({ $0.address == "z"}).count, 1)
        for msg in res  {
            let m = msg as! StartMessage
            XCTAssertFalse(m.muted)
            XCTAssertEqual(m.reference, audioStem.reference)
            XCTAssert(m.type == .Start)
        }
    }
    
    func testSetAudioStem_manyPerformersHotToCold() {
    
        /*
        From:
        
            [ stem: SOME, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        To:
            [ stem: nil, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        */
        
        let ps = ["x", "y", "z"]
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(ps), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: nil, performers: Set(ps), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem.reference : 2, audioStem2.reference : 2])
        XCTAssertEqual(res.count, 3)
        XCTAssertEqual(res.filter({ $0.address == "x"}).count, 1)
        XCTAssertEqual(res.filter({ $0.address == "y"}).count, 1)
        XCTAssertEqual(res.filter({ $0.address == "z"}).count, 1)
        for msg in res {
            XCTAssert((msg as! StopMessage).type == .Stop)
        }
    }
}

/* Test: Mute */

extension MessageTransformerTests {
    
    func testToggleMute_offToOn_noPerformers() {
        
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: [], M: 1, S: 0 ]
        
        */
        
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: true, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 0)
    }
    
    func testToggleMute_OnToOff_noPerformers() {
        
        /*
        From:
        
            [ stem: SOME, performers: [], M: 1, S: 0 ]
        
        To:
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        */
        
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: true, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 0)
    }
    
    func testToggeMute_offToOn_onePerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 1, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: true, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 1)
        let msg = res.first as! MuteMessage
        XCTAssertEqual(msg.address, "x")
    }
    
    func testToggeMute_onToOff_onePerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 1, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: true, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 1)
        let msg = res.first as! UnmuteMessage
        XCTAssertEqual(msg.address, "x")
        XCTAssertEqual(msg.type, MessageType.Unmute)
    }
    
    func testToggeMute_offToOn_manyPerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x", "y", "z"], M: 1, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x", "y", "z"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x","y","z"]), isMuted: true, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 3)
        XCTAssertEqual(res.filter({$0.address == "x"}).count, 1)
        XCTAssertEqual(res.filter({$0.address == "y"}).count, 1)
        XCTAssertEqual(res.filter({$0.address == "z"}).count, 1)
        for msg in res {
            XCTAssertTrue(msg.type == .Mute)
        }
    }
    
    func testToggeMute_onToOff_manyPerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x", "y", "z"], M: 1, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x", "y", "z"]), isMuted: true, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x","y","z"]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        XCTAssertEqual(res.count, 3)
        XCTAssertEqual(res.filter({$0.address == "x"}).count, 1)
        XCTAssertEqual(res.filter({$0.address == "y"}).count, 1)
        XCTAssertEqual(res.filter({$0.address == "z"}).count, 1)
        for msg in res  {
            XCTAssertTrue(msg.type == .Unmute)
        }
    }
}

/* Test: Solo */

extension MessageTransformerTests {
    
    func testToggleSolo_offToOn_noPerformers() {
        
        /*
            From:
        
                [ stem: SOME, performers: [], M: 0, S: 0 ]
        
            To:
                [ stem: SOME, performers: [], M: 0, S: 1 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: true, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        
        XCTAssertEqual(res.count, 0)
    }
    
    func testToggleSolo_OnToOff_noPerformers() {
        
        /*
            From:
        
                [ stem: SOME, performers: [], M: 0, S: 1 ]
        
            To:
                [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: true, isSolo: true, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        
        XCTAssertEqual(res.count, 0)
    }
    
    
    func testToggleSolo_offToOn_oneWorkspace_onePerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 1 ]
        
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: true, isAntiSolo: false)

        
        let res = MessageTransformer.transform(Set([from_ws]), toSuite: Set([to_ws]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        
        XCTAssertEqual(res.count, 0)
    }
    
    func testToggleSolo_offToOn_twoWorkspaces_toggleWithPerformer() {
        
        /*
        From:
        
            [ stem: SOME1, performers: [], M: 0, S: 0 ]
            [ stem: SOME2, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME1, performers: [], M: 0, S: 0 ]
            [ stem: SOME2, performers: ["x"], M: 0, S: 1 ]
        
        */
        
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let from_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: true, isAntiSolo: false)

        let res = MessageTransformer.transform(Set([from_ws1, from_ws2]), toSuite: Set([to_ws1, to_ws2]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        
        XCTAssertEqual(res.count, 0)
    }
    
    
    func testToggleSolo_offToOn_twoWorkspaces_toggleWithoutPerformer() {
        
        /*
        From:
        
            [ stem: SOME1, performers: [], M: 0, S: 0, AS: 0 ]
            [ stem: SOME2, performers: ["x"], M: 0, S: 0, AS: 0 ]
        
        To:
            [ stem: SOME1, performers: [], M: 0, S: 1, AS: 0]
            [ stem: SOME2, performers: ["x"], M: 0, S: 0, AS: 1 ]
        
        */
        
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let from_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: true, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: true)

        let res = MessageTransformer.transform(Set([from_ws1, from_ws2]), toSuite: Set([to_ws1, to_ws2]), timestamp: 0, sessionTimestamp: 1, referenceTimestamps: [audioStem2.reference : 2])
        
        XCTAssertEqual(res.count, 1)
    }
}

