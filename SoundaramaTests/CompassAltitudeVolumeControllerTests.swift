//
//  CompassAltitudeVolumeControllerTests.swift
//  Soundarama
//
//  Created by Jamie Cox on 16/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import XCTest
@testable import Soundarama

class CompassAltitudeVolumeControllerTests: XCTestCase { }

extension CompassAltitudeVolumeControllerTests {
    
    func test_calculate_no_relevant_tags() {
        
        let tagged_path = TaggedAudioPath(tags: Set(["SOME"]), path: "x", loopLength: 1)
        let tagged_paths = Set([tagged_path])
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: 0)
        
        XCTAssertEqual(ret[tagged_path], 0)
    }
    
    func test_calculate_altitude_tag() {

        let tagged_path = TaggedAudioPath(tags: Set(["Altitude:0"]), path: "x", loopLength: 1)
        let tagged_paths = Set([tagged_path])
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: 0)
        
        XCTAssertEqual(ret[tagged_path], 1)
    }
}