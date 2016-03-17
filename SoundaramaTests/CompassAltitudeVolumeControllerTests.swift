//
//  CompassAltitudeVolumeControllerTests.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import XCTest
@testable import Soundarama

class CompassAltitudeVolumeControllerTests: XCTestCase {

    var tagged_paths: Set<TaggedAudioPath>!
    
    var north_high: TaggedAudioPath!
    var north_middle: TaggedAudioPath!
    var north_low: TaggedAudioPath!
    
    var south_high: TaggedAudioPath!
    var south_middle: TaggedAudioPath!
    var south_low: TaggedAudioPath!
    
    override func setUp() {
        
        super.setUp()
        
        let north_high_tags = Set(["Compass:NORTH", "Altitude:HIGH"])
        let north_middle_tags = Set(["Compass:NORTH", "Altitude:MIDDLE"])
        let north_low_tags = Set(["Compass:NORTH", "Altitude:LOW"])
        
        let south_high_tags = Set(["Compass:SOUTH", "Altitude:HIGH"])
        let south_middle_tags = Set(["Compass:SOUTH", "Altitude:MIDDLE"])
        let south_low_tags = Set(["Compass:SOUTH", "Altitude:LOW"])
        
        north_high = TaggedAudioPath(tags: north_high_tags, path: "x", loopLength: 2)
        north_middle = TaggedAudioPath(tags: north_middle_tags, path: "x", loopLength: 2)
        north_low = TaggedAudioPath(tags: north_low_tags, path: "x", loopLength: 2)
        
        south_high = TaggedAudioPath(tags: south_high_tags, path: "x", loopLength: 2)
        south_middle = TaggedAudioPath(tags: south_middle_tags, path: "x", loopLength: 2)
        south_low = TaggedAudioPath(tags: south_low_tags, path: "x", loopLength: 2)
        
        tagged_paths = Set([north_high, north_middle, north_low, south_high, south_middle, south_low])
    }
}

extension CompassAltitudeVolumeControllerTests {
    
    /* Altitude == 0 */
    
    func test_middle_interpolation_north() {

        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    func test_middle_interpolation_north_east() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 45, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.75)
        XCTAssertEqual(ret[south_middle], 0.25)
    }
    
    func test_middle_interpolation_east() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_middle_interpolation_south_east() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 135, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.25)
        XCTAssertEqual(ret[south_middle], 0.75)
    }
    
    func test_middle_interpolation_south() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_middle_interpolation_south_west() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 135, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.25)
        XCTAssertEqual(ret[south_middle], 0.75)
    }
    
    func test_middle_interpolation_west() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_middle_interpolation_north_west() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 315, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.75)
        XCTAssertEqual(ret[south_middle], 0.25)
    }
}

extension CompassAltitudeVolumeControllerTests {
    
    /* High Altitude */
    
    
}
