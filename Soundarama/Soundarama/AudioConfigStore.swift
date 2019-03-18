//
//  AudioConfigStore.swift
//  Soundarama
//
//  Created by Jamie Cox on 30/03/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct AudioConfigurationStore {
    
    static func getConfiguration() -> AudioConfiguration {
        
        let jsonPath = NSBundle.mainBundle().pathForResource("AudioConfig", ofType: "json", inDirectory: "Sounds")!
        let data = NSData(contentsOfFile: jsonPath)!
        let json = JSON(data: data)
        let ll = json["audio_loop_length"].number!.doubleValue
        let fl = json["audio_file_length"].number!.doubleValue
        return AudioConfiguration(loopLength: ll, audioFileLength: fl)
    }
}
