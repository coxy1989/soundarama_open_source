//
//  AudioController.m
//  Soundarama
//
//  Created by Jamie Cox on 04/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define CheckError(x,y) [self checkError:x msg:y];

@implementation AudioController

AudioFileID mAudioFile;
AUGraph _graph;

- (void)start {
    CheckError(AUGraphStart(_graph), @"AUGraphStart failed");
}

- (void)stop {
    CheckError(AUGraphStop(_graph), @"AUGraphStop failed");
}

- (void)checkError:(OSStatus)status msg:(NSString *)msg {
    assert(status == 0);
}

- (void)setup {
    
        //create a new AUGraph
        CheckError(NewAUGraph(&_graph), @"NewAUGraph failed");
        // opening the graph opens all contained audio units but does not allocate any resources yet
        CheckError(AUGraphOpen(_graph), @"AUGraphOpen failed");
        // now initialize the graph (causes resources to be allocated)
        CheckError(AUGraphInitialize(_graph), @"AUGraphInitialize failed");
    
        AUNode outputNode;
        {
            AudioComponentDescription outputAudioDesc = {0};
            outputAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
            outputAudioDesc.componentType = kAudioUnitType_Output;
            outputAudioDesc.componentSubType = kAudioUnitSubType_RemoteIO;
            // adds a node with above description to the graph
            CheckError(AUGraphAddNode(_graph, &outputAudioDesc, &outputNode), @"AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed");
        }
        
        AUNode filePlayerNode;
        {
            AudioComponentDescription fileplayerAudioDesc = {0};
            fileplayerAudioDesc.componentType = kAudioUnitType_Generator;
            fileplayerAudioDesc.componentSubType = kAudioUnitSubType_AudioFilePlayer;
            fileplayerAudioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
            // adds a node with above description to the graph
            CheckError(AUGraphAddNode(_graph, &fileplayerAudioDesc, &filePlayerNode), @"AUGraphAddNode[kAudioUnitSubType_AudioFilePlayer] failed");
        }
        
        //Connect the nodes
        CheckError((AUGraphConnectNodeInput(_graph, filePlayerNode, 0, outputNode, 0)), @"AUGraphConnectNodeInput failed");
    
        // configure the file player
        // tell the file player unit to load the file we want to play
        {
            AudioStreamBasicDescription inputFormat; // input file's data stream description
            AudioFileID inputFile; // reference to your input file
            
            // open the input audio file and store the AU ref in _player
            CFURLRef songURL = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:@"23" withExtension:@"aif"];
            CheckError(AudioFileOpenURL(songURL, kAudioFileReadPermission, 0, &inputFile), @"AudioFileOpenURL failed");
            
            //create an empty MyAUGraphPlayer struct
            AudioUnit fileAU;
            
            // get the reference to the AudioUnit object for the file player graph node
            CheckError(AUGraphNodeInfo(_graph, filePlayerNode, NULL, &fileAU), @"AUGraphNodeInfo failed");
            
            // get and store the audio data format from the file
            UInt32 propSize = sizeof(inputFormat);
            CheckError(AudioFileGetProperty(inputFile, kAudioFilePropertyDataFormat, &propSize, &inputFormat), @"couldn't get file's data format");
            
            CheckError(AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduledFileIDs, kAudioUnitScope_Global, 0, &(inputFile), sizeof((inputFile))), @"AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileIDs] failed");
            
            UInt64 nPackets;
            UInt32 propsize = sizeof(nPackets);
            CheckError(AudioFileGetProperty(inputFile, kAudioFilePropertyAudioDataPacketCount, &propsize, &nPackets), @"AudioFileGetProperty[kAudioFilePropertyAudioDataPacketCount] failed");
            
            // tell the file player AU to play the entire file
            ScheduledAudioFileRegion rgn;
            memset (&rgn.mTimeStamp, 0, sizeof(rgn.mTimeStamp));
            rgn.mTimeStamp.mFlags = kAudioTimeStampSampleTimeValid;
            rgn.mTimeStamp.mSampleTime = 0;
            rgn.mCompletionProc = NULL;
            rgn.mCompletionProcUserData = NULL;
            rgn.mAudioFile = inputFile;
            rgn.mLoopCount = 1;
            rgn.mStartFrame = 0;
            rgn.mFramesToPlay = nPackets * inputFormat.mFramesPerPacket;
            
            CheckError(AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduledFileRegion, kAudioUnitScope_Global, 0,&rgn, sizeof(rgn)), @"AudioUnitSetProperty[kAudioUnitProperty_ScheduledFileRegion] failed");
            
            // prime the file player AU with default values
            UInt32 defaultVal = 0;
            CheckError(AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduledFilePrime, kAudioUnitScope_Global, 0, &defaultVal, sizeof(defaultVal)), @"AudioUnitSetProperty[kAudioUnitProperty_ScheduledFilePrime] failed");
            
            // tell the file player AU when to start playing (-1 sample time means next render cycle)
            AudioTimeStamp startTime;
            memset (&startTime, 0, sizeof(startTime));
            startTime.mFlags = kAudioTimeStampSampleTimeValid;
            startTime.mSampleTime = -1;
            CheckError(AudioUnitSetProperty(fileAU, kAudioUnitProperty_ScheduleStartTimeStamp, kAudioUnitScope_Global, 0, &startTime, sizeof(startTime)), @"AudioUnitSetProperty[kAudioUnitProperty_ScheduleStartTimeStamp]");
            
            // file duration
            //double duration = (nPackets * _player.inputFormat.mFramesPerPacket) / _player.inputFormat.mSampleRate;
        }            
}

@end
