//
//  AudioController.h
//  Soundarama
//
//  Created by Jamie Cox on 04/12/2015.
//  Copyright © 2015 Touchpress Ltd. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

@interface AudioController : NSObject

- (void)setup;

- (void)start;

- (void)stop;

@end
