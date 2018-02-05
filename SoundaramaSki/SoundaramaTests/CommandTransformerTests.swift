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

/*I
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
        let res = DJCommandTransformer.transform(Set([to]), toSuite: Set([from]))
        
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
        let res = DJCommandTransformer.transform([from_ws1], toSuite: [to_ws1])
        
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
        let res = DJCommandTransformer.transform([from_ws1], toSuite: [to_ws1])
        
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
        let res = DJCommandTransformer.transform([from_ws1], toSuite: [to_ws1])
        let expected = DJStartCommand(performer: "x", reference: audioStem.reference, muted: false)
        
        XCTAssertTrue(res.first as! DJStartCommand == expected)
    }
    
    
    func testAddedPerformer_Hot_Empty_Muted_WS() {
        
        /*
        From:
        
            [ stem: SOME, performers: [], M: 1, S: 0 ]
        
        To:
            [ stem: SOME, performers: ["x"], M: 1, S: 0 ]
        
        */
        
        let id = "A"
        let newPerformer = "x"
        let from_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([]), isMuted: true, isSolo: false, isAntiSolo: false)
        let to_ws1 = Workspace(identifier: id, audioStem: audioStem, performers: Set([newPerformer]), isMuted: true, isSolo: false, isAntiSolo: false)
        let res = DJCommandTransformer.transform([from_ws1], toSuite: [to_ws1])
        let cmd = res.first as! DJStartCommand
        let expected = DJStartCommand(performer: "x", reference: audioStem.reference, muted: true)
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(expected, cmd)
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
        let res = DJCommandTransformer.transform([from_ws1, from_ws2], toSuite: [to_ws1, to_ws2])
        let cmd = res.first as! DJStartCommand
        let expected = DJStartCommand(performer: "x", reference: audioStem.reference, muted: true)
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(cmd, expected)
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
        let res = DJCommandTransformer.transform([from_ws1], toSuite: [to_ws1])
        let cmd = res.first as! DJStopCommand
        let expected = DJStopCommand(performer: "x")
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(cmd, expected)
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
        let to_ws1 = Workspace(identifier: id1, audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: id2, audioStem: audioStem2, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = DJCommandTransformer.transform([from_ws1, from_ws2], toSuite: [to_ws1, to_ws2])
        let cmd = res.first as! DJStartCommand
        let expected = DJStartCommand(performer: "x", reference: audioStem2.reference, muted: false)
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(cmd, expected)
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
        let to_ws1 = Workspace(identifier: "A", audioStem: audioStem, performers: Set([]), isMuted: false, isSolo: false, isAntiSolo: false)
        let to_ws2 = Workspace(identifier: "B", audioStem: audioStem2, performers: Set([pb, pa]), isMuted: false, isSolo: false, isAntiSolo: false)
        let res = DJCommandTransformer.transform([from_ws1, from_ws2], toSuite: [to_ws1, to_ws2])
        let cmd = res.first as! DJStartCommand
        let expected = DJStartCommand(performer: pa, reference: audioStem2.reference, muted: false)
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(cmd, expected)
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])

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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let cmd = res.first as! DJStartCommand
        let expected = DJStartCommand(performer: "x", reference: audioStem.reference, muted: false)
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(cmd, expected)
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let cmd = res.first as! DJStopCommand
        let expect = DJStopCommand(performer: "x")
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(cmd, expect)
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let cmd = res.first as! DJStartCommand
        let expect = DJStartCommand(performer: "x", reference: audioStem2.reference, muted: false)
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(expect, cmd)
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let expect_1 = DJStartCommand(performer: "x", reference: audioStem.reference, muted: false)
        let expect_2 = DJStartCommand(performer: "y", reference: audioStem.reference, muted: false)
        let expect_3 = DJStartCommand(performer: "z", reference: audioStem.reference, muted: false)
        
        XCTAssertEqual(res.count, 3)
        XCTAssertTrue(res.contains( {$0 as? DJStartCommand == expect_1 }))
        XCTAssertTrue(res.contains( {$0 as? DJStartCommand == expect_2 }))
        XCTAssertTrue(res.contains( {$0 as? DJStartCommand == expect_3 }))
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let expect_1 = DJStopCommand(performer: "x")
        let expect_2 = DJStopCommand(performer: "y")
        let expect_3 = DJStopCommand(performer: "z")
        
        XCTAssertEqual(res.count, 3)
        XCTAssertTrue(res.contains( {$0 as? DJStopCommand == expect_1 }))
        XCTAssertTrue(res.contains( {$0 as? DJStopCommand == expect_2 }))
        XCTAssertTrue(res.contains( {$0 as? DJStopCommand == expect_3 }))
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let cmd = res.first as! DJMuteCommand
        let expect = DJMuteCommand(performer: "x")
            
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(expect, cmd)
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let cmd = res.first as! DJUnmuteCommand
        let expect = DJUnmuteCommand(performer: "x")
        
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(expect, cmd)
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let expect_1 = DJMuteCommand(performer: "x")
        let expect_2 = DJMuteCommand(performer: "y")
        let expect_3 = DJMuteCommand(performer: "z")
        
        XCTAssertEqual(res.count, 3)
        XCTAssertTrue(res.contains( {$0 as? DJMuteCommand == expect_1 }))
        XCTAssertTrue(res.contains( {$0 as? DJMuteCommand == expect_2 }))
        XCTAssertTrue(res.contains( {$0 as? DJMuteCommand == expect_3 }))
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        let expect_1 = DJUnmuteCommand(performer: "x")
        let expect_2 = DJUnmuteCommand(performer: "y")
        let expect_3 = DJUnmuteCommand(performer: "z")
        
        XCTAssertEqual(res.count, 3)
        XCTAssertTrue(res.contains( {$0 as? DJUnmuteCommand == expect_1 }))
        XCTAssertTrue(res.contains( {$0 as? DJUnmuteCommand == expect_2 }))
        XCTAssertTrue(res.contains( {$0 as? DJUnmuteCommand == expect_3 }))
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        
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
        let res = DJCommandTransformer.transform([from_ws], toSuite: [to_ws])
        
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
        let res = DJCommandTransformer.transform([from_ws1, from_ws2], toSuite: [to_ws1, to_ws2])
        
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
        let res = DJCommandTransformer.transform([from_ws1, from_ws2], toSuite: [to_ws1, to_ws2])
        
        XCTAssertEqual(res.count, 1)
    }
}
*/