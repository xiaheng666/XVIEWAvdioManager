//
//  BBHoldToSpeakButton.m
//  BBVoiceRecordDemo
//
//  Created by 谢国碧 on 2016/12/10.
//
//

#import "BBHoldToSpeakButton.h"
#import "UIImage+BBVoiceRecord.h"
#import "UIColor+BBVoiceRecord.h"

@implementation BBHoldToSpeakButton

- (void)updateRecordButtonStyle:(BBVoiceRecordState)state
{
    [self setTitle:LongBtn forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage bb_imageWithColor:[UIColor whiteColor] withSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    
    if (state == BBVoiceRecordState_Recording) {
        [self setTitle:LooseBtn forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage bb_imageWithColor:[UIColor colorWithHex:0xC6C7CA] withSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    }
    else if (state == BBVoiceRecordState_ReleaseToCancel)
    {
        [self setTitle:LongBtn forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage bb_imageWithColor:[UIColor colorWithHex:0xC6C7CA] withSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    }
    else if (state == BBVoiceRecordState_RecordCounting)
    {
        [self setTitle:LooseBtn forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage bb_imageWithColor:[UIColor colorWithHex:0xC6C7CA] withSize:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    }
}

@end
