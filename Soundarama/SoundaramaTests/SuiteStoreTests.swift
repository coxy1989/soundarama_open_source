//
//  SuiteStoreTests.swift
//  Soundarama
//
//  Created by Jamie Cox on 31/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import XCTest
@testable import Soundarama

class SuiteStoreTests: XCTestCase { }

/* Test: Init */

extension SuiteStoreTests {
    
    func testInitNumber() {
        
        let store = SuiteStore(number: 0)
        XCTAssertEqual(store.suite.count, 0)
        
        let store1 = SuiteStore(number: 1)
        XCTAssertEqual(store1.suite.count, 1)
        
        let store2 = SuiteStore(number: 2)
        XCTAssertEqual(store2.suite.count, 2)
        
        let store10 = SuiteStore(number: 10)
        XCTAssertEqual(store10.suite.count, 10)
    }
    
    func testInitDefault() {
        
        let store10 = SuiteStore(number: 10)
        for ws in store10.suite {
            XCTAssertNotNil(ws.identifier)
            XCTAssertNil(ws.audioStem)
            XCTAssertEqual(ws.performers.count, 0)
            XCTAssertFalse(ws.isMuted)
            XCTAssertFalse(ws.isSolo)
            XCTAssertFalse(ws.isAntiSolo)
        }
    }
}

/* Test: Add Performer */

extension SuiteStoreTests {
    
    func testAddPerformer_addsPerformer() {
        
        /*
            Prestate:
        
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: false
                    aSolo: false
                }
            
            Expected Poststate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: ["p"]
                    muted: false
                    solo: false
                    aSolo: false
                }
        */
        
        let store = SuiteStore(number:0)
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        store.suite = Set([ws1])
        store.addPerformer("p", workspaceID: store.suite.first!.identifier)
        XCTAssertEqual(store.suite.first!.performers, ["p"])
    }
    
    func testAddPerformer_removesPerformer() {
        
        /*
            Prestate:
            
            {
                id: A
                aud: nil
                pfmrs: ["p"]
                muted: false
                solo: false
                aSolo: false
            }
            {
                id: B
                aud: nil
                pfmrs: []
                muted: false
                solo: false
                aSolo: false
            }
            
            Expected Poststate:
        
            {
                id: A
                aud: nil
                pfmrs: []
                muted: false
                solo: false
                aSolo: false
            }
            {
                id: B
                aud: nil
                pfmrs: ["p"]
                muted: false
                solo: false
                aSolo: false
            }
            */
        
        let p = "p"
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let ws2 = Workspace(identifier: "B", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1, ws2])
        
        store.addPerformer(p, workspaceID: ws2.identifier)
        let poststate = store.suite
        XCTAssertEqual(poststate.filter({$0.identifier == "A"}).first!.performers.count, 0)
        XCTAssertEqual(poststate.filter({$0.identifier == "B"}).first!.performers, [p])

    }
}

/* Test: Remove Performer */

extension SuiteStoreTests {
    
    func testRemovePerformer_removesPerformer() {
        
        /*
            Prestate:
        
            {
                id: A
                aud: nil
                pfmrs: ["p"]
                muted: false
                solo: false
                aSolo: false
            }
            
            Expected Poststate:
            
            {
                id: A
                aud: nil
                pfmrs: []
                muted: false
                solo: false
                aSolo: false
            }
        */
        
        let p = "p"
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set([p]), isMuted: false, isSolo: false, isAntiSolo: false)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1])
        
        store.removePerformer(p)
        XCTAssertEqual(store.suite.first!.performers.count, 0)
    }
}

/* Test: Set AudioStem */

extension SuiteStoreTests {
    
    func testSetAudioStem_setsAudioStem() {
        
            /*
            Prestate:
            
            {
                id: A
                aud: nil
                pfmrs: []
                muted: false
                solo: false
                aSolo: false
            }
            
            Expected Poststate:
            
            {
                id: A
                aud: SOME
                pfmrs: []
                muted: false
                solo: false
                aSolo: false
            }
            */
        
        let aud = AudioStem(name: "x", colour: UIColor.redColor(), category: "x", reference: "y", loopLength: 69.0)
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1])
        store.setAudioStem(aud, workspaceID: ws1.identifier)
        XCTAssertTrue(store.suite.first!.audioStem! == aud)
    }
}

/* Test: Toggle Mute */

extension SuiteStoreTests {
    
    func testToggleMute_setsMuteOn() {
        
        /*
            Prestate:
            
            {
                id: A
                aud: nil
                pfmrs: []
                muted: false
                solo: false
                aSolo: false
            }
            
            Expected Poststate:
            
            {
                id: A
                aud: nil
                pfmrs: []
                muted: true
                solo: false
                aSolo: false
            }
        */
        
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1])
        store.toggleMute(ws1.identifier)
        XCTAssertTrue(store.suite.first!.isMuted)
    }
    
    func testToggleMute_setsMuteOff() {
        
        /*
            Prestate:
            
            {
                id: A
                aud: nil
                pfmrs: []
                muted: true
                solo: false
                aSolo: false
            }
            
            Expected Poststate:
            
            {
                id: A
                aud: nil
                pfmrs: []
                muted: false
                solo: false
                aSolo: false
            }
        */
        
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: true, isSolo: false, isAntiSolo: false)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1])
        store.toggleMute(ws1.identifier)
        XCTAssertFalse(store.suite.first!.isMuted)
    }
}

/* Test Toggle Solo */

extension SuiteStoreTests {
    
    func testToggleSolo_setsSoloTrue() {
        
            /*
                Prestate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: false
                    aSolo: false
                }
                
                Expected Poststate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: false
                    aSolo: true
                }
            */
        
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1])
        store.toggleSolo(ws1.identifier)
        XCTAssertTrue(store.suite.first!.isSolo)
    }
    
    func testToggleSolo_setsSoloFalse() {
        
            /*
                Prestate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: true
                    aSolo: true
                }
                
                Expected Poststate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: false
                    aSolo: true
                }
            */
        
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: true, isAntiSolo: false)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1])
        store.toggleSolo(ws1.identifier)
        XCTAssertFalse(store.suite.first!.isSolo)
    }
    
    func testToggleSolo_setsAntiSoloTrue() {
        
            /*
                Prestate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: false
                    aSolo: false
                }
                {
                    id: B
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: false
                    aSolo: false
                }
                
                Expected Poststate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: true
                    aSolo: false
                }
                {
                    id: B
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: false
                    aSolo: true
                }
            */
        
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let ws2 = Workspace(identifier: "B", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1, ws2])
        store.toggleSolo(ws1.identifier)
        let A = store.suite.filter({$0.identifier == "A"}).first!
        XCTAssertTrue(A.isSolo)
        XCTAssertFalse(A.isAntiSolo)
        let B = store.suite.filter({$0.identifier == "B"}).first!
        XCTAssertFalse(B.isSolo)
       XCTAssertTrue(B.isAntiSolo)
    }
    
    func testToggleSolo_setsAntiSoloFalse() {
        
            /*
                Prestate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: true
                    aSolo: false
                }
                {
                    id: B
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: false
                    aSolo: true
                }
                
                Expected Poststate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: false
                    aSolo: false
                }
                {
                    id: B
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: false
                    aSolo: false
                }
            */
        
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: true, isAntiSolo: false)
        let ws2 = Workspace(identifier: "B", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: true)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1, ws2])
        store.toggleSolo(ws1.identifier)
        let A = store.suite.filter({$0.identifier == "A"}).first!
        XCTAssertFalse(A.isSolo)
        XCTAssertFalse(A.isAntiSolo)
        let B = store.suite.filter({$0.identifier == "B"}).first!
        XCTAssertFalse(B.isSolo)
       XCTAssertFalse(B.isAntiSolo)
    }
    
    func testToggleSolo_doesNotSetAntiSoloFalse() {
        
            /*
                Prestate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: true
                    aSolo: false
                }
                {
                    id: B
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: true
                    aSolo: false
                }
                {
                    id: C
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: false
                    aSolo: true
                }
                
                Expected Poststate:
                
                {
                    id: A
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: false
                    aSolo: true
                }
                {
                    id: B
                    aud: nil
                    pfmrs: []
                    muted: true
                    solo: true
                    aSolo: false
                }
                {
                    id: C
                    aud: nil
                    pfmrs: []
                    muted: false
                    solo: false
                    aSolo: true
                }
            */
        
        let ws1 = Workspace(identifier: "A", audioStem: nil, performers: Set(), isMuted: false, isSolo: true, isAntiSolo: false)
        let ws2 = Workspace(identifier: "B", audioStem: nil, performers: Set(), isMuted: false, isSolo: true, isAntiSolo: false)
        let ws3 = Workspace(identifier: "C", audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: true)
        let store = SuiteStore(number:0)
        store.suite = Set([ws1, ws2, ws3])
        store.toggleSolo(ws1.identifier)
        let A = store.suite.filter({$0.identifier == "A"}).first!
        XCTAssertFalse(A.isSolo)
        XCTAssertTrue(A.isAntiSolo)
        let B = store.suite.filter({$0.identifier == "B"}).first!
        XCTAssertTrue(B.isSolo)
        XCTAssertFalse(B.isAntiSolo)
        let C = store.suite.filter({$0.identifier == "C"}).first!
        XCTAssertFalse(C.isSolo)
        XCTAssertTrue(C.isAntiSolo)
    }
}
