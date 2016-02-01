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
    
    var transformer: MessageTransformer!
    var audioStem: AudioStem!
    var audioStem2: AudioStem!
    
    override func setUp() {
        
        transformer = MessageTransformer(timestamp: 1, sessionTimestamp: 1.1)
        audioStem = AudioStem(name: "x", colour: UIColor.redColor(), category: "y", reference: "z", loopLength: 1.0)
        audioStem2 = AudioStem(name: "a", colour: UIColor.blueColor(), category: "b", reference: "c", loopLength: 2.0)
        super.setUp()
    }
    
    override func tearDown() {
        
        super.tearDown()
        transformer = nil
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
        
            Expect:
        
                []
        */
        
        let from = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let to = from
        let res = transformer.transform(Set([to]), toSuite: Set([from]))
        XCTAssertEqual(res.count, 0)
    }
    
    func testNoChange_hotOccupiedWS() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        Expect:
        
            []
        */
        
        let p = "x"
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = transformer.transform([from_ws1], toSuite: [to_ws1])
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
        
        Expect:
        
            []
        */
        
        let id = "A"
        let newPerformer = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: nil, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: nil, performers: Set([newPerformer]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = transformer.transform([from_ws1], toSuite: [to_ws1])
        XCTAssertEqual(res.count, 0)
    }
    
    func testAddedPerformer_Hot_Empty_Unmuted_WS() {
    
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Start)
                    muted: false) 
                }
            ]
        */
        
        let id = "A"
        let newPerformer = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: nil, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([newPerformer]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = transformer.transform([from_ws1], toSuite: [to_ws1])
        XCTAssert(res.count == 1)
        if let msg = res.first {
            XCTAssertEqual(msg.address, newPerformer)
            XCTAssertFalse(msg.muted)
            XCTAssertEqual(msg.reference, audioStem.reference)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssert(msg.command == .Start)
        }
    }
    
    func testAddedPerformer_Hot_Empty_Muted_WS() {
        
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 1, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Start)
                    muted: false)
                }
            ]
        */
        
        let id = "A"
        let newPerformer = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([newPerformer]), isMuted: true, isSolo: false, isAntiSolo: false)
        let res = transformer.transform([from_ws1], toSuite: [to_ws1])
        XCTAssertEqual(res.count, 1)
        if let msg = res.first {
            XCTAssertTrue(msg.muted)
        }
    }
    
    func testAddedPerformer_Hot_Empty_Unmuted_AntiSolo_WS() {
        
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0, AS: 1 ]
            [ stem: SOME2, performers: [], M: 0, S: 1, AS: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 0, AS: 1 ]
            [ stem: SOME2, performers: [], M: 0, S: 1, AS: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Start)
                    muted: true)
                }
            ]
        */
        
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: true, isAntiSolo: true)
        let from_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set([]), isMuted: false, isSolo: true, isAntiSolo: false)
        
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: true)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(), isMuted: true, isSolo: true, isAntiSolo: false)
        
        let res = transformer.transform([from_ws1, from_ws2], toSuite: [to_ws1, to_ws2])
        
        XCTAssertEqual(res.count, 1)
        if let msg = res.first {
            XCTAssertTrue(msg.muted)
            XCTAssertEqual(msg.address, "x")
            XCTAssertEqual(msg.reference, audioStem.reference)
        }
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
            
            Expect:
            
                [
                    {
                        address: "x"
                        timestamp: TODO
                        sessionTimestamp: TODO
                        as: (ref: SOME2.ref, ll: SOME2.ll, cmd: .Stop)
                        muted: false)
                    }
                ]
        */
    
        let id = "A"
        let p = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = transformer.transform([from_ws1], toSuite: [to_ws1])
        XCTAssertEqual(res.count, 1)
        if let msg = res.first {
            XCTAssert(msg.address == p)
            XCTAssertFalse(msg.muted)
            XCTAssertEqual(msg.reference, audioStem.reference)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssert(msg.command == .Stop)
        }
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
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME2.ref, ll: SOME2.ll, cmd: .Start)
                    muted: false)
                }
            ]
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
        
        let res = transformer.transform(suite1, toSuite: suite2)
        XCTAssertEqual(res.count, 1)
        
        if let msg = res.first {
            XCTAssertTrue(msg.reference == audioStem2.reference)
            XCTAssertTrue(msg.loopLength == audioStem2.loopLength)
            XCTAssertTrue(msg.command == .Start)
        }
    }
    
    func testMovedPerformer_toHotOccupiedUnmutedWS_fromHotUnmutedWorkspace() {
    
        /*
        From:
        
            [ stem: SOME1, performers: ["x"], M: 0, S: 0 ]
            [ stem: SOME2, performers: ["y"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME1, performers: [], M: 0, S: 0 ]
            [ stem: SOME2, performers: ["y", "x"], M: 0, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME2.ref, ll: SOME2.ll, cmd: .Start)
                    muted: false)
                }
            ]
        */
        
        let pa = "y"
        let pb = "x"
        
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([pa]), isMuted: false, isSolo: false, isAntiSolo: false)
        let from_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set([pb]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite1 = Set([from_ws1, from_ws2])
        
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set([pb, pa]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite2 = Set([to_ws1, to_ws2])
        
        let res = transformer.transform(suite1, toSuite: suite2)
        XCTAssertEqual(res.count, 1)
        
        if let msg = res.first {
            XCTAssertEqual(msg.address, pa)
            XCTAssertFalse(msg.muted)
            XCTAssertEqual(msg.reference, audioStem2.reference)
            XCTAssertEqual(msg.loopLength, audioStem2.loopLength)
            XCTAssert(msg.command == .Start)
        }
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
        
        Expect:
        
            [ ]
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 0)
    }
    
    func testSetAudioStem_noPerformersHotToCold() {
    
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: nil, performers: [], M: 0, S: 0 ]
        
        Expect:
        
            [ ]
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 0)
    }
    
    func testSetAudioStem_noPerformersHotToHot() {
    
        /*
        From:
        
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        To:
            [ stem: SOME2, performers: [], M: 0, S: 0 ]
        
        Expect:
        
            [ ]
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem2, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 0)
    }
    
    func testSetAudioStem_onePerformerColdToHot() {
    
        /*
        From:
        
            [ stem: nil, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Start)
                    muted: false)
                }
            ]
        */
        
        let p = "x"
        
        let from_ws = Workspace(identifier: "A", audioStem: nil, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 1)
        if let msg = res.first {
            XCTAssertEqual(msg.address, p)
            XCTAssertFalse(msg.muted)
            XCTAssertEqual(msg.reference, audioStem.reference)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssert(msg.command == .Start)
        }
    }
    
    func testSetAudioStem_onePerformerHotToCold() {
    
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: nil, performers: ["x"], M: 0, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Stop)
                    muted: false)
                }
            ]
        */
        
        let p = "x"
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: nil, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 1)
        if let msg = res.first {
            XCTAssertEqual(msg.address, p)
            XCTAssertFalse(msg.muted)
            XCTAssertEqual(msg.reference, audioStem.reference)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssert(msg.command == .Stop)
        }
    }
    
    func testSetAudioStem_onePerformerHotToHot() {
    
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME2, performers: ["x"], M: 0, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME2.ref, ll: SOME2.ll, cmd: .Start)
                    muted: false)
                }
            ]
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 1)
        if let m = res.first {
            
        }
    }
    
    func testSetAudioStem_manyPerformersColdToHot() {
    
        /*
        From:
        
            [ stem: nil, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Start)
                    muted: false)
                }
                {
                    address: "y"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Start)
                    muted: false)
                }
                {
                    address: "z"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Start)
                    muted: false)
                }
            ]
        */
        
        let ps = ["x", "y", "z"]
        
        let from_ws = Workspace(identifier: "A", audioStem: nil, performers: Set(ps), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(ps), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 3)
        XCTAssertEqual(res.filter({ $0.address == "x"}).count, 1)
        XCTAssertEqual(res.filter({ $0.address == "y"}).count, 1)
        XCTAssertEqual(res.filter({ $0.address == "z"}).count, 1)
        for msg in res {
            XCTAssertFalse(msg.muted)
            XCTAssertEqual(msg.reference, audioStem.reference)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssert(msg.command == .Start)
            
        }
    }
    
    func testSetAudioStem_manyPerformersHotToCold() {
    
        /*
        From:
        
            [ stem: SOME, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        To:
            [ stem: nil, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Stop)
                    muted: false)
                }
                {
                    address: "y"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Stop)
                    muted: false)
                }
                {
                    address: "z"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .Stop)
                    muted: false)
                }
            ]
        */
        
        let ps = ["x", "y", "z"]
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(ps), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: nil, performers: Set(ps), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 3)
        XCTAssertEqual(res.filter({ $0.address == "x"}).count, 1)
        XCTAssertEqual(res.filter({ $0.address == "y"}).count, 1)
        XCTAssertEqual(res.filter({ $0.address == "z"}).count, 1)
        for msg in res {
            XCTAssertFalse(msg.muted)
            XCTAssertEqual(msg.reference, audioStem.reference)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssert(msg.command == .Stop)
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
        
        Expect:
        
            []
        */
        
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: true, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 0)
    }
    
    func testToggleMute_OnToOff_noPerformers() {
        
        /*
        From:
        
            [ stem: SOME, performers: [], M: 1, S: 0 ]
        
        To:
            [ stem: SOME, performers: [], M: 0, S: 0 ]
        
        Expect:
        
            []
        */
        
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: true, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 0)
    }
    
    func testToggeMute_offToOn_onePerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 1, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .ToggleMute)
                    muted: true)
                }
            ]
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: true, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 1)
        if let msg = res.first {
            XCTAssertEqual(msg.address, "x")
            XCTAssertEqual(msg.muted, true)
            XCTAssertTrue(msg.command == .ToggleMute)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssertEqual(msg.reference, audioStem.reference)
        }
    }
    
    func testToggeMute_onToOff_onePerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 1, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME.ref, ll: SOME.ll, cmd: .ToggleMute)
                    muted: true)
                }
            ]
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: true, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 1)
        if let msg = res.first {
            XCTAssertEqual(msg.address, "x")
            XCTAssertEqual(msg.muted, false)
            XCTAssertTrue(msg.command == .ToggleMute)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssertEqual(msg.reference, audioStem.reference)
        }
    }
    
    func testToggeMute_offToOn_manyPerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x", "y", "z"], M: 1, S: 0 ]
        
        Expect:
        
            []
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x", "y", "z"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x","y","z"]), isMuted: true, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 3)
        XCTAssertEqual(res.filter({$0.address == "x"}).count, 1)
        XCTAssertEqual(res.filter({$0.address == "y"}).count, 1)
        XCTAssertEqual(res.filter({$0.address == "z"}).count, 1)
        for msg in res {
            XCTAssertTrue(msg.muted)
            XCTAssertTrue(msg.command == .ToggleMute)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssertEqual(msg.reference, audioStem.reference)
        }
    }
    
    func testToggeMute_onToOff_manyPerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x", "y", "z"], M: 1, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x", "y", "z"], M: 0, S: 0 ]
        
        Expect:
        
            []
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x", "y", "z"]), isMuted: true, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x","y","z"]), isMuted: false, isSolo: false, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        XCTAssertEqual(res.count, 3)
        XCTAssertEqual(res.filter({$0.address == "x"}).count, 1)
        XCTAssertEqual(res.filter({$0.address == "y"}).count, 1)
        XCTAssertEqual(res.filter({$0.address == "z"}).count, 1)
        for msg in res {
            XCTAssertFalse(msg.muted)
            XCTAssertTrue(msg.command == .ToggleMute)
            XCTAssertEqual(msg.loopLength, audioStem.loopLength)
            XCTAssertEqual(msg.reference, audioStem.reference)
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
        
            Expect:
        
                []
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: true, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        
        XCTAssertEqual(res.count, 0)
    }
    
    func testToggleSolo_OnToOff_noPerformers() {
        
        /*
            From:
        
                [ stem: SOME, performers: [], M: 0, S: 1 ]
        
            To:
                [ stem: SOME, performers: [], M: 0, S: 0 ]
        
            Expect:
        
                []
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: true, isSolo: true, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        
        XCTAssertEqual(res.count, 0)
    }
    
    
    func testToggleSolo_offToOn_oneWorkspace_onePerformer() {
        
        /*
        From:
        
            [ stem: SOME, performers: ["x"], M: 0, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 0, S: 1 ]
        
        Expect:
        
            [ ]
        */
        
        let from_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws = Workspace(identifier: "A", audioStem: audioStem, performers: Set(["x"]), isMuted: false, isSolo: true, isAntiSolo: false)

        
        let res = transformer.transform(Set([from_ws]), toSuite: Set([to_ws]))
        
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
        
        Expect:
        
            [ ]
        */
        
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let from_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: true, isAntiSolo: false)

        let res = transformer.transform(Set([from_ws1, from_ws2]), toSuite: Set([to_ws1, to_ws2]))
        
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
        
        Expect:
        
            [
                {
                    address: "x"
                    timestamp: TODO
                    sessionTimestamp: TODO
                    as: (ref: SOME2.ref, ll: SOME2.ll, cmd: .ToggleMute)
                    muted: true)
                }
            ]
        */
        
        let from_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let from_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: false)
        
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set(), isMuted: false, isSolo: true, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set(["x"]), isMuted: false, isSolo: false, isAntiSolo: true)

        let res = transformer.transform(Set([from_ws1, from_ws2]), toSuite: Set([to_ws1, to_ws2]))
        
        XCTAssertEqual(res.count, 1)
    }
}
