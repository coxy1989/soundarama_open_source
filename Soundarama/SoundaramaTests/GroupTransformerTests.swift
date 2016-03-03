//
//  GroupTransformerTests.swift
//  Soundarama
//
//  Created by Jamie Cox on 03/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import XCTest
@testable import Soundarama

class GroupTransformerTests: XCTestCase {}

/* Test: Transform (created component) */

extension GroupTransformerTests {
    
    func test_transform_null() {
        
        /* There are no groups in either the 'from' or the 'to' sets of groups */
        
        let from: Set<Group> = Set()
        let to: Set<Group> = Set()
     
        let expect_created: GroupCreationRecord? = nil
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
    }
    
    func test_transform_equal() {
        
        /* There is no difference between the 'to' and 'from' sets of groups */
        
        let from: Set<Group> = Set([Group(members: Set(["x", "y"]))])
        let to: Set<Group> = Set([Group(members: Set(["x", "y"]))])
        
        let expect_created: GroupCreationRecord? = nil
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
    }
    
    func test_transform_created_first_group() {

        /* A new group was created from two performers and there are no existing groups */
        
        let new_performers = Set(["x", "y"])
        let new_group = Group(members: new_performers)
        
        let from: Set<Group> = Set()
        let to: Set<Group> = Set([new_group])

        let record = GroupCreationRecord(groupID: new_group.id(), sourcePerformers: new_performers, sourceGroupIDs: Set([]))
        
        let expect_created = record
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
    }
    
    func test_transform_created_second_group() {
        
        /* A new group was created from two performers and there is one existing group */
    
        let existing_performers = Set(["a", "b"])
        let existing_group = Group(members: existing_performers)
        
        let new_performers = Set(["x", "y"])
        let new_group = Group(members: new_performers)
        
        let from: Set<Group> = Set([existing_group])
        let to: Set<Group> = Set([existing_group, new_group])
        
        let record = GroupCreationRecord(groupID: new_group.id(), sourcePerformers: new_performers, sourceGroupIDs: Set([]))
        
        let expect_created = record
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
        
    }
    
    func test_transform_created_third_group() {
        
        /* A new group was created from two performers and there is one existing group */
    
        let existing_performers_a = Set(["a", "b"])
        let existing_group_a = Group(members: existing_performers_a)
        
        let existing_performers_b = Set(["1", "2"])
        let existing_group_b = Group(members: existing_performers_b)
        
        let new_performers = Set(["x", "y"])
        let new_group = Group(members: new_performers)
        
        let from: Set<Group> = Set([existing_group_a, existing_group_b])
        let to: Set<Group> = Set([existing_group_a, existing_group_b ,new_group])
        
        let record = GroupCreationRecord(groupID: new_group.id(), sourcePerformers: new_performers, sourceGroupIDs: Set([]))
        
        let expect_created = record
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
        
    }
    
    func test_transform_merged_two_existing_groups() {
        
        /* A new group was created from two existing groups */
        
        let existing_performers_a = Set(["a", "b"])
        let existing_group_a = Group(members: existing_performers_a)
        
        let existing_performers_b = Set(["1", "2"])
        let existing_group_b = Group(members: existing_performers_b)
        
        let new_group = Group(members: Set(["a", "b", "1", "2"]))
        
        let from: Set<Group> = Set([existing_group_a, existing_group_b])
        let to: Set<Group> = Set([new_group])
        
        let record = GroupCreationRecord(groupID: new_group.id(), sourcePerformers: Set([]), sourceGroupIDs: Set([existing_group_a.id(), existing_group_b.id()]))
     
        let expect_created = record
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
    }
    
    func test_transform_merged_three_existing_groups() {
        
        /* A new group was created from three existing groups */
        
        let existing_performers_a = Set(["a", "b"])
        let existing_group_a = Group(members: existing_performers_a)
        
        let existing_performers_b = Set(["1", "2"])
        let existing_group_b = Group(members: existing_performers_b)
        
        let existing_performers_c = Set(["x", "y"])
        let existing_group_c = Group(members: existing_performers_c)
        
        let new_group = Group(members: Set(["a", "b", "1", "2", "x", "y"]))
        
        let from: Set<Group> = Set([existing_group_a, existing_group_b, existing_group_c])
        let to: Set<Group> = Set([new_group])
        
        let record = GroupCreationRecord(groupID: new_group.id(), sourcePerformers: Set([]), sourceGroupIDs: Set([existing_group_a.id(), existing_group_b.id(), existing_group_c.id()]))
        
        let expect_created = record
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
    }
    
    func test_transform_merged_one_group_with_one_performer() {
    
        /* A new group was created from one existing group and one performer */
        
        let existing_performers_a = Set(["a", "b"])
        let existing_group_a = Group(members: existing_performers_a)
        
        let new_performer = "x"
        
        let new_group = Group(members: Set(["a", "b", new_performer]))
        
        let from = Set([existing_group_a])
        let to: Set<Group> = Set([new_group])
        
        let record = GroupCreationRecord(groupID: new_group.id(), sourcePerformers: Set([new_performer]), sourceGroupIDs: Set([existing_group_a.id()]))
        
        let expect_created = record
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
        
    }
    
    func test_transform_merged_one_group_with_two_performers() {
    
        /* A new group was created from one existing group and two performers */
        
        let existing_performers_a = Set(["a", "b"])
        let existing_group_a = Group(members: existing_performers_a)
        
        let new_performer_a = "x"
        let new_performer_b = "y"
        
        let new_group = Group(members: Set(["a", "b", new_performer_a, new_performer_b]))
        
        let from = Set([existing_group_a])
        let to: Set<Group> = Set([new_group])
        
        let record = GroupCreationRecord(groupID: new_group.id(), sourcePerformers: Set([new_performer_a, new_performer_b]), sourceGroupIDs: Set([existing_group_a.id()]))
        
        let expect_created = record
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
        
    }
    
    func test_transform_merged_two_groups_with_two_performers() {
    
        /* A new group was created from two existing groups and two performers */
        
        let existing_performers_a = Set(["a", "b"])
        let existing_group_a = Group(members: existing_performers_a)
        
        let existing_performers_b = Set(["1", "2"])
        let existing_group_b = Group(members: existing_performers_b)
        
        let new_performer_a = "x"
        let new_performer_b = "y"
        
        let new_group = Group(members: Set(["a", "b", "1", "2", new_performer_a, new_performer_b]))
        
        let from = Set([existing_group_a, existing_group_b])
        let to: Set<Group> = Set([new_group])
        
        let record = GroupCreationRecord(groupID: new_group.id(), sourcePerformers: Set([new_performer_a, new_performer_b]), sourceGroupIDs: Set([existing_group_a.id(), existing_group_b.id()]))
        
        let expect_created = record
        let expect_destroyed: Group? = nil
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
    }
}

extension GroupTransformerTests {
    
    /* Test: Transform (destroyed component) */
    
    func test_transform_destroyed_group() {
        
        let existing_performers_a = Set(["a", "b"])
        let existing_group_a = Group(members: existing_performers_a)
     
        let from = Set([existing_group_a])
        let to: Set<Group> = Set()
        
        let expect_created: GroupCreationRecord? = nil
        let expect_destroyed = existing_group_a
        let output = GroupTransformer.transform(from, toGroups: to)
        
        XCTAssertEqual(output.created, expect_created)
        XCTAssertEqual(output.destroyed, expect_destroyed)
    }
}
