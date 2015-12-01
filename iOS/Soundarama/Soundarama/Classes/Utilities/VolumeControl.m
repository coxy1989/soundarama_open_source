//
//  VolumeControl.m
//  Bananarama
//
//  Created by Tom Weightman on 07/09/2015.
//  Copyright (c) 2015 Touchpress Ltd. All rights reserved.
//

#import "VolumeControl.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation VolumeControl

+ (void)setVolumeToMax
{
    [[MPMusicPlayerController applicationMusicPlayer] setVolume: 1.0];
}

@end