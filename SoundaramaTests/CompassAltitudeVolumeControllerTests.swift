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
    
    let hll = CompassAltitudeVolumeController.high_lower_limit
    let hul = CompassAltitudeVolumeController.high_upper_limit
    
    let lul = CompassAltitudeVolumeController.low_upper_limit
    let lll = CompassAltitudeVolumeController.low_lower_limit
    
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
    
    func test_compass_north_altitiude_EQ_zero() {

        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    func test_compass_nort_east__altitiude_EQ_zero() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 45, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.75)
        XCTAssertEqual(ret[south_middle], 0.25)
    }
    
    func test_compass_east_altitiude_EQ_zero() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compass_south_east_altitiude_EQ_zero() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 135, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.25)
        XCTAssertEqual(ret[south_middle], 0.75)
    }
    
    func test_compass_south_altitiude_EQ_zero() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compass_south_west_altitiude_EQ_zero() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 135, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.25)
        XCTAssertEqual(ret[south_middle], 0.75)
    }
    
    func test_compass_west_altitiude_EQ_zero() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, altitudeValue: 0)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compass_north_west_altitiude_EQ_zero() {
        
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
    
      /* Altitude == CompassAltitudeVolumeController.high_lower_limit */
    
    func test_compasss_north_altitude_EQ_hll() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: CompassAltitudeVolumeController.high_lower_limit)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    func test_compasss_east_altitude_EQ_hll() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, altitudeValue: CompassAltitudeVolumeController.high_lower_limit)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compasss_south_altitude_EQ_hll() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, altitudeValue: CompassAltitudeVolumeController.high_lower_limit)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0)
        XCTAssertEqual(ret[south_middle], 1)
    }

    func test_compasss_west_altitude_EQ_hll() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, altitudeValue: CompassAltitudeVolumeController.high_lower_limit)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
}

extension CompassAltitudeVolumeControllerTests {
    
    /* Altitude > CompassAltitudeVolumeController.high_lower_limit  */
    
    func test_compasss_north_altitude_GT_hll_quartrange() {
        
        let range = hul - hll
        
        let quartrange = (range * 0.25) + hll
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: quartrange)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 0.25)
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    func test_compasss_north_altitude_GT_hll_midrange() {
        
        let range = hul - hll
        
        let midrange = (range * 0.5) + hll
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: midrange)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 0.5)
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    func test_compasss_north_altitude_EQ_hul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: hul)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 1)
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    func test_compasss_north_altitude_GT_hul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: hul + 999)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 1)
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    func test_compasss_east_altitude_GT_hll_quartrange() {
        
        let range = hul - hll
        
        let midrange = (range * 0.25) + hll
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, altitudeValue: midrange)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[south_high], 0.125)
        XCTAssertEqual(ret[north_high], 0.125)
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compasss_east_altitude_GT_hll_midrange() {
        
        let range = hul - hll
        
        let midrange = (range * 0.5) + hll
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, altitudeValue: midrange)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[south_high], 0.25)
        XCTAssertEqual(ret[north_high], 0.25)
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compasss_east_altitude_EQ_hul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, altitudeValue: hul)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[south_high], 0.5)
        XCTAssertEqual(ret[north_high], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compasss_east_altitude_GT_hul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, altitudeValue: hul + 999)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[south_high], 0.5)
        XCTAssertEqual(ret[north_high], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compasss_south_altitude_GT_hll_quartrange() {
        
        let range = hul - hll
        
        let midrange = (range * 0.25) + hll
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, altitudeValue: midrange)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_middle], 0)
        
        XCTAssertEqual(ret[south_high], 0.25)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compasss_south_altitude_GT_hll_midrange() {
        
        let range = hul - hll
        
        let midrange = (range * 0.5) + hll
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, altitudeValue: midrange)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_middle], 0)
        
        XCTAssertEqual(ret[south_high], 0.5)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compasss_south_altitude_EQ_hul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, altitudeValue: hul)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_middle], 0)
        
        XCTAssertEqual(ret[south_high], 1)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compasss_south_altitude_GT_hul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, altitudeValue: hul + 999)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_middle], 0)
        
        XCTAssertEqual(ret[south_high], 1)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compasss_west_altitude_GT_hll_quartrange() {
        
        let range = hul - hll
        
        let midrange = (range * 0.25) + hll
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, altitudeValue: midrange)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 0.125)
        XCTAssertEqual(ret[south_high], 0.125)
        XCTAssertEqual(ret[south_middle], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
    }
    
    func test_compasss_west_altitude_GT_hll_midrange() {
        
        let range = hul - hll
        
        let midrange = (range * 0.5) + hll
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, altitudeValue: midrange)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 0.25)
        XCTAssertEqual(ret[south_high], 0.25)
        XCTAssertEqual(ret[south_middle], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
    }
    
    func test_compasss_west_altitude_EQ_hul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, altitudeValue: hul)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 0.5)
        XCTAssertEqual(ret[south_high], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
    }
    
    func test_compasss_west_altitude_GT_hul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, altitudeValue: hul + 999)
        
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_high], 0.5)
        XCTAssertEqual(ret[south_high], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
        XCTAssertEqual(ret[north_middle], 0.5)
    }
}

extension CompassAltitudeVolumeControllerTests {
    
    /* Altitude == CompassAltitudeVolumeController.low_upper_limit */
    
    func test_compasss_north_altitude_EQ_lul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: CompassAltitudeVolumeController.low_upper_limit)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 1)
        XCTAssertEqual(ret[south_middle], 0)
    }
    
    func test_compasss_east_altitude_EQ_lul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 90, altitudeValue: CompassAltitudeVolumeController.low_upper_limit)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
    
    func test_compasss_south_altitude_EQ_lul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 180, altitudeValue: CompassAltitudeVolumeController.low_upper_limit)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0)
        XCTAssertEqual(ret[south_middle], 1)
    }
    
    func test_compasss_west_altitude_EQ_lul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 270, altitudeValue: CompassAltitudeVolumeController.low_upper_limit)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[north_low], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        
        XCTAssertEqual(ret[north_middle], 0.5)
        XCTAssertEqual(ret[south_middle], 0.5)
    }
}

extension CompassAltitudeVolumeControllerTests {
    
    /* Altitude > CompassAltitudeVolumeController.high_lower_limit  */

    func test_compasss_north_altitude_LT_lul_quartrange() {
        
        let range = lul - lll
        
        let quartrange = lul - (range * 0.25)
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: quartrange)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[south_middle], 0)
        
        XCTAssertEqual(ret[north_low], 0.25)
        XCTAssertEqual(ret[north_middle], 1)
    }
    
    func test_compasss_north_altitude_LT_lul_midrange() {
        
        let range = hul - hll
        
        let midrange = lul - (range * 0.5)
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: midrange)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[south_middle], 0)
        
        XCTAssertEqual(ret[north_low], 0.5)
        XCTAssertEqual(ret[north_middle], 1)
    }
    
    func test_compasss_north_altitude_EQ_lll() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: lll)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[south_middle], 0)
        
        XCTAssertEqual(ret[north_low], 1)
        XCTAssertEqual(ret[north_middle], 1)
    }
    
    func test_compasss_north_altitude_GT_lul() {
        
        let ret = CompassAltitudeVolumeController.calculateVolume(tagged_paths, compassValue: 0, altitudeValue: lll - 999)
        
        XCTAssertEqual(ret[north_high], 0)
        XCTAssertEqual(ret[south_high], 0)
        XCTAssertEqual(ret[south_low], 0)
        XCTAssertEqual(ret[south_middle], 0)
        
        XCTAssertEqual(ret[north_low], 1)
        XCTAssertEqual(ret[north_middle], 1)
    }
}
