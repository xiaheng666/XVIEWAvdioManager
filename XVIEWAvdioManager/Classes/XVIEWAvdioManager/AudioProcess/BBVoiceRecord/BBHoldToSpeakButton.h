//
//  BBHoldToSpeakButton.h
//  BBVoiceRecordDemo
//
//  Created by 谢国碧 on 2016/12/10.
//
//

#import <UIKit/UIKit.h>
#import "BBVoiceRecordHeaderDefine.h"
#define LongBtn        @"长按录音"
#define LooseBtn       @"松开结束"
@interface BBHoldToSpeakButton : UIButton

- (void)updateRecordButtonStyle:(BBVoiceRecordState)state;

@end
