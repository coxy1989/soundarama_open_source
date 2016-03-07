//
//  GroupStoreTests.swift
//  Soundarama
//
//  Created by Jamie Cox on 01/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import XCTest
@testable import Soundarama

class GroupStoreTests: XCTestCase {
    
    var store: GroupStore!
    
    override func setUp() {
        
        super.setUp()
        store = GroupStore()
        
    }
    
    override func tearDown() {
        
        store = nil
        super.tearDown()
    }
}

/* Test: Init */

extension GroupStoreTests {
    
    func testInit_no_groups() {
        
        XCTAssertEqual(store.groups.count, 0, "Should not create a group")
    }
}

/* Test: Create Group */

extension GroupStoreTests {
    
    func testCreateGroup_null_case() {
        
        let prestate = store.groups
        store.createGroup(performers: Set([]), groupIDs: Set([]))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 0)
        XCTAssertEqual(prestate, poststate, "Should not create a group")
    }
    
    func testCreateGroup_one_performer() {
        
        let prestate = store.groups
        store.createGroup(performers: Set(["x"]), groupIDs: Set([]))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 0)
        XCTAssertEqual(prestate, poststate, "Should not create a group ")
    }
    
    func testCreateGroup_two_performers() {
        
        let input = Set(["x", "y"])
        store.createGroup(performers: input, groupIDs: Set([]))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 1)
        XCTAssertEqual(poststate.first!.members, input, "Should create one group containing the two performers from the input")
    }
    
    func testCreateGroup_three_performers() {
        
        let input = Set(["x", "y", "z"])
        store.createGroup(performers: input, groupIDs: Set([]))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 1)
        XCTAssertEqual(poststate.first!.members, input, "Should create one group containing the two performers from the input")
    }
    
    func testCreateGroup_one_two_performer_group() {
        
        let input = Set(arrayLiteral: Group(members: Set(["x", "y"])))
        store.groups = input
        let prestate = store.groups
        
        store.createGroup(performers: Set(), groupIDs: Set(input.map({$0.id()})))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 1)
        XCTAssertEqual(prestate, poststate, "Should mot create a new group")
    }
    
    func testCreateGroup_one_three_performer_group() {
        
        let prestate = store.groups
        let input = Set(arrayLiteral: Group(members: Set(["x","y","z"])))
        store.createGroup(performers: Set(), groupIDs: Set(input.map({$0.id()})))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 0)
        XCTAssertEqual(prestate, poststate, "Should mot create a group")
    }
    
    func testCreateGroup_two_two_performer_groups() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let input = Set([group1, group2])
        
        store.groups = input
        store.createGroup(performers: Set(), groupIDs: Set(input.map({$0.id()})))
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "a", "b"]))])
        
        XCTAssertEqual(poststate.count, 1 ,"Should create one group containing the four performers from the input")
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_three_two_performer_groups() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let group3 = Group(members: Set(["1","2"]))
        let input = Set([group1, group2, group3])
        
        store.groups = input
        store.createGroup(performers: Set(), groupIDs: Set(input.map({$0.id()})))
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y" ,"a", "b", "1", "2"]))])
        
        XCTAssertEqual(poststate.count, 1 ,"Should create one group containing the six performers from the input")
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_two_two_performer_groups_removes_existing() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let input = Set(arrayLiteral: group1, group2)
        
        store.groups = Set([group1, group2])
        store.createGroup(performers: Set(), groupIDs: Set(input.map({$0.id()})))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "a", "b"]))])
        
        XCTAssertEqual(poststate.count, 1 ,"Should create one group containing the four performers from the input and remove the pre-existing groups")
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_three_two_performer_groups_remove_existing() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let group3 = Group(members: Set(["1","2"]))
        let input = Set(arrayLiteral: group1, group2, group3)
        
        store.groups = Set([group1, group2, group3])
        store.createGroup(performers: Set(), groupIDs: Set(input.map({$0.id()})))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "a", "b", "1", "2"]))])
        
        XCTAssertEqual(poststate.count, 1 ,"Should create one group containing the six performers from the input and remove the pre-existing groups")
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_two_two_performer_groups_does_not_remove_existing() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let input = Set(arrayLiteral: group1, group2)
        
        let preExistingGroup = Group(members: Set(["1","2"]))
        store.groups = Set([preExistingGroup, group1, group2])
        store.createGroup(performers: Set(), groupIDs: Set(input.map({$0.id()})))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "a", "b"])), Group(members: Set(["1", "2"]))])
        
        XCTAssertEqual(poststate.count, 2 ,"Should create one group containing the four performers from the input and keep the pre-existing group")
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_one_performer_one_two_performer_group() {
        
        let group1 = Group(members: Set(["x","y"]))
        let performer = "1"
        
        store.groups = Set([group1])
        store.createGroup(performers: Set([performer]), groupIDs: Set([group1].map({$0.id()})))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "1"]))])
        
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_one_performer_two_two_performer_groups() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let performer = "1"
        
        store.groups = Set([group1, group2])
        store.createGroup(performers: Set([performer]), groupIDs: Set([group1, group2].map({$0.id()})))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "1", "a", "b"]))])
        
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_two_performers_two_two_performer_groups() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let performers = ["1", "2"]
        
        store.groups = Set([group1, group2])
        store.createGroup(performers: Set(performers), groupIDs: Set([group1, group2].map({$0.id()})))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "1", "a", "b", "2"]))])
        
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_one_performer_two_two_performer_groups_removes_existing() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let performer = "1"
        
        store.groups = Set([group1, group2])
        
        store.createGroup(performers: Set([performer]), groupIDs: Set([group1, group2].map({$0.id()})))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "1", "a", "b"]))])
        
        XCTAssertEqual(poststate, expected)
    }
}

extension GroupStoreTests {
    
    /* Test: isValidGroup */
    
    /* Performers */
    
    func testIsValidGroup_null_case() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: [], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set(), groupIDs: Set(), inSuite: suite)
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_one_performer_not_in_suite() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: [], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set(["x"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_one_performer_in_suite() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["x"], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set(["x"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_two_performers_not_in_suite() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: [], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set(["x", "y"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertTrue(outcome)
    }
    
    func testIsValidGroup_two_performers_in_suite_in_same_workspace() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["x", "y"], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set(["x", "y"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertTrue(outcome)
    }
    
    func testIsValidGroup_two_performers_in_suite_in_different_workspaces() {
        
        let ws1 = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["x"], isMuted: false, isSolo: false, isAntiSolo: false)
        let ws2 = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["y"], isMuted: false, isSolo: false, isAntiSolo: false)
        let suite = Suite([ws1, ws2])
        
        let outcome = store.isValidGroup( Set(["x", "y"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_three_performers_in_suite_in_different_workspaces() {
        
        let ws1 = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["x"], isMuted: false, isSolo: false, isAntiSolo: false)
        let ws2 = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["y"], isMuted: false, isSolo: false, isAntiSolo: false)
        let ws3 = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["z"], isMuted: false, isSolo: false, isAntiSolo: false)
        let suite = Suite([ws1, ws2, ws3])
        
        let outcome = store.isValidGroup(Set(["x", "y", "z"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_two_performers_one_in_workspace_one_not() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["x"], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set(["x", "y"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_two_performers_two_in_workspace_one_not() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["x", "y"], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set(["x", "y", "z"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_two_performers_one_in_workspace_two_not() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: ["x"], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set(["x", "y", "z"]), groupIDs: Set(), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    /* Groups */
    
    func testIsValidGroup_one_group_not_in_workspace() {
        
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: [], isMuted: false, isSolo: false, isAntiSolo: false)])
        
        let outcome = store.isValidGroup( Set([]), groupIDs: Set([1]), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_one_group_in_workspace() {
        
        let group = Group(members: Set(["x"]))
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: group.members, isMuted: false, isSolo: false, isAntiSolo: false)])
        
        store.groups = Set([group])
        
        let outcome = store.isValidGroup( Set([]), groupIDs: Set([group.id()]), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_one_group_in_workspace_one_not() {
        
        let group1 = Group(members: Set(["x", "y"]))
        let group2 = Group(members: Set(["a", "b"]))
        let ws1 = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(["x", "y"]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite = Set([ws1])
        
        store.groups = Set([group1, group2])
        
        let outcome = store.isValidGroup( Set([]), groupIDs: Set([group1.id(), group2.id()]), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_two_groups_in_same_workspace() {
        
        let group1 = Group(members: Set(["x", "y"]))
        let group2 = Group(members: Set(["a", "b"]))
        let suite = Set([Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(["x", "y", "a", "b"]), isMuted: false, isSolo: false, isAntiSolo: false)])
        
        store.groups = Set([group1, group2])
        
        let outcome = store.isValidGroup( Set([]), groupIDs: Set([group1.id(), group2.id()]), inSuite: suite)
        
        XCTAssertTrue(outcome)
    }
    
    func testIsValidGroup_two_groups_in_different_workspaces() {
        
        let group1 = Group(members: Set(["x", "y"]))
        let group2 = Group(members: Set(["a", "b"]))
        let ws1 = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(["x", "y"]), isMuted: false, isSolo: false, isAntiSolo: false)
        let ws2 = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(["a", "b"]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite = Set([ws1, ws2])
        
        store.groups = Set([group1, group2])
        
        let outcome = store.isValidGroup( Set([]), groupIDs: Set([group1.id(), group2.id()]), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }

    func testIsValidGroup_one_performer_in_workspace_one_group_not_in_workspace() {
        
        let group = Group(members: Set(["x", "y"]))
        let ws = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(["1"]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite = Set([ws])
        
        store.groups = Set([group])
        
        let outcome = store.isValidGroup( Set(["1"]), groupIDs: Set([group.id()]), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testIsValidGroup_one_performer_not_in_workspace_one_group_in_workspace() {
        
        let group = Group(members: Set(["x", "y"]))
        let ws = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(["x", "y"]), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite = Set([ws])
        
        store.groups = Set([group])
        
        let outcome = store.isValidGroup( Set(["1"]), groupIDs: Set([group.id()]), inSuite: suite)
        
        XCTAssertFalse(outcome)
    }
    
    func testValidGroup_one_performer_one_group_neither_in_workspace() {
        
        let group = Group(members: Set(["x", "y"]))
        let ws = Workspace(identifier: NSUUID().UUIDString, audioStem: nil, performers: Set(), isMuted: false, isSolo: false, isAntiSolo: false)
        let suite = Set([ws])
        
        store.groups = Set()
        
        let outcome = store.isValidGroup( Set(["1"]), groupIDs: Set([group.id()]), inSuite: suite)
        
        XCTAssertTrue(outcome)
    }
}
