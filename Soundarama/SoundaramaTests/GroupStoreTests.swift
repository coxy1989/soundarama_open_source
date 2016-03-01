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
        store.createGroup(performers: Set([]), groups: Set([]))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 0)
        XCTAssertEqual(prestate, poststate, "Should not create a group")
    }
    
    func testCreateGroup_one_performer() {
        
        let prestate = store.groups
        store.createGroup(performers: Set(["x"]), groups: Set([]))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 0)
        XCTAssertEqual(prestate, poststate, "Should not create a group ")
    }
    
    func testCreateGroup_two_performers() {
        
        let input = Set(["x", "y"])
        store.createGroup(performers: input, groups: Set([]))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 1)
        XCTAssertEqual(poststate.first!.members, input, "Should create one group containing the two performers from the input")
    }
    
    func testCreateGroup_three_performers() {
        
        let input = Set(["x", "y", "z"])
        store.createGroup(performers: input, groups: Set([]))
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 1)
        XCTAssertEqual(poststate.first!.members, input, "Should create one group containing the two performers from the input")
    }
    
    func testCreateGroup_one_empty_group() {
        
        let input = Set(arrayLiteral: Group(members: Set()))
        store.createGroup(performers: Set(), groups: input)
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 0)
    }
    
    func testCreateGroup_one_two_performer_group() {
        
        let prestate = store.groups
        let input = Set(arrayLiteral: Group(members: Set(["x", "y"])))
        store.createGroup(performers: Set(), groups: input)
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 0)
        XCTAssertEqual(prestate, poststate, "Should mot create a group")
    }
    
    func testCreateGroup_one_three_performer_group() {
        
        let prestate = store.groups
        let input = Set(arrayLiteral: Group(members: Set(["x","y","z"])))
        store.createGroup(performers: Set(), groups: input)
        let poststate = store.groups
        XCTAssertEqual(poststate.count, 0)
        XCTAssertEqual(prestate, poststate, "Should mot create a group")
    }
    
    func testCreateGroup_two_two_performer_groups() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let input = Set([group1, group2])
        store.createGroup(performers: Set(), groups: input)
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
        store.createGroup(performers: Set(), groups: input)
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
        store.createGroup(performers: Set(), groups: input)
        
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
        store.createGroup(performers: Set(), groups: input)
        
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
        store.groups = Set([preExistingGroup])
        store.createGroup(performers: Set(), groups: input)
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "a", "b"])), Group(members: Set(["1", "2"]))])
        
        XCTAssertEqual(poststate.count, 2 ,"Should create one group containing the four performers from the input and keep the pre-existing group")
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_one_performer_one_two_performer_group() {
        
        let group1 = Group(members: Set(["x","y"]))
        let performer = "1"
        
        store.createGroup(performers: Set([performer]), groups: Set([group1]))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "1"]))])
        
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_one_performer_two_two_performer_groups() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let performer = "1"
        
        store.createGroup(performers: Set([performer]), groups: Set([group1, group2]))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "1", "a", "b"]))])
        
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_two_performers_two_two_performer_groups() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let performers = ["1", "2"]
        
        store.createGroup(performers: Set(performers), groups: Set([group1, group2]))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "1", "a", "b", "2"]))])
        
        XCTAssertEqual(poststate, expected)
    }
    
    func testCreateGroup_one_performer_two_two_performer_groups_removes_existing() {
        
        let group1 = Group(members: Set(["x","y"]))
        let group2 = Group(members: Set(["a","b"]))
        let performer = "1"
        
        store.groups = Set([group1, group2])
        
        store.createGroup(performers: Set([performer]), groups: Set([group1, group2]))
        
        let poststate = store.groups
        let expected = Set([Group(members: Set(["x", "y", "1", "a", "b"]))])
        
        XCTAssertEqual(poststate, expected)
    }
}
