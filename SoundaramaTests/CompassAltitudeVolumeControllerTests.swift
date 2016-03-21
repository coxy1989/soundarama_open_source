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
        
        let north_high_tags = Set([CompassTag.North.rawValue, LevelTag.High.rawValue])
        let north_middle_tags = Set([CompassTag.North.rawValue, LevelTag.Middle.rawValue])
        let north_low_tags = Set([CompassTag.North.rawValue, LevelTag.Low.rawValue])
        
        let south_high_tags = Set([CompassTag.South.rawValue, LevelTag.High.rawValue])
        let south_middle_tags = Set([CompassTag.South.rawValue, LevelTag.Middle.rawValue])
        let south_low_tags = Set([CompassTag.South.rawValue, LevelTag.Low.rawValue])
        
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
    
    /* Level == Middle */
    
    func test_compass_north_level_EQ_middle() {

        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, level: .Middle)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    
    func test_compass_nort_east_level_EQ_middle() {
        
       let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 45, level: .Middle)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.75)
        XCTAssertEqual(ret[south_middle], 0.25)
    }
    
    func test_compass_east_level_EQ_middle() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, level: .Middle)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compass_south_east_level_EQ_middle() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 135, level: .Middle)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.25)
        XCTAssertEqual(ret[south_middle], 0.75)
    }
    
    func test_compass_south_level_EQ_middle() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, level: .Middle)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compass_south_west_level_EQ_middle() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 135, level: .Middle)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.25)
        XCTAssertEqual(ret[south_middle], 0.75)
    }
    
    func test_compass_west_level_EQ_middle() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, level: .Middle)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compass_north_west_level_EQ_middle() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 315, level: .Middle)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.75)
        XCTAssertEqual(ret[south_middle], 0.25)
    }
}

extension CompassAltitudeVolumeControllerTests {
    
    /* Level == High */
    
    func test_compasss_north_level_EQ_high() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, level: .High)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[south_middle], 0)
        
        XCTAssertEqual(ret[north_high], 1)
        XCTAssertEqual(ret[north_middle], 1)
    }
    
    func test_compasss_east_level_EQ_high() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, level: .High)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 0.5)
        XCTAssertEqual(ret[south_high], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compasss_south_altitude_EQ_high() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, level: .High)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[north_middle], 0)
        
        XCTAssertEqual(ret[south_high], 1)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compasss_west_altitude_EQ_high() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, level: .High)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 0.5)
        XCTAssertEqual(ret[south_high], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
}

extension CompassAltitudeVolumeControllerTests {
    
    /* Level == Low */
    
    func test_compasss_north_level_EQ_low() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, level: .Low)
        
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[south_middle], 0)
        XCTAssertEqual(ret[north_high], 0)
        

        XCTAssertEqual(ret[north_low], 1)
        XCTAssertEqual(ret[north_middle], 1)
    }
    
    func test_compasss_east_level_EQ_low() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, level: .Low)
        
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[south_high], 0)
        
        XCTAssertEqual(ret[north_low], 0.5)
        XCTAssertEqual(ret[south_low], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compasss_south_altitude_EQ_low() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, level: .Low)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[north_middle], 0)
        
        XCTAssertEqual(ret[south_low], 1)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compasss_west_altitude_EQ_low() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, level: .Low)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[south_high], 0)
        
        XCTAssertEqual(ret[north_low], 0.5)
        XCTAssertEqual(ret[south_low], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
}
