//
//  AudioConfigurationTests.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

import XCTest
@testable import Soundarama

class AudioConfigurationTests: XCTestCase {
    
    let config = AudioConfigurationStore.getConfiguration()
}

extension AudioConfigurationTests {
    
    func test_loop_length_is_valid() {
        
        let multiple = config.audioFileLength / config.loopLength
        let integer_multiple = floor(multiple)
        let diff = multiple - integer_multiple
        print(diff)
        XCTAssertTrue( diff < 0.0001)
    }
}
