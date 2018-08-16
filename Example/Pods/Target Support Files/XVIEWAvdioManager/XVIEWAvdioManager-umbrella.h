#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AudioPlayerManager.h"
#import "AudioProcessManager.h"
#import "AudioRecordView.h"
#import "BBHoldToSpeakButton.h"
#import "BBVoiceRecordController.h"
#import "BBVoiceRecordHeaderDefine.h"
#import "BBVoiceRecordPowerAnimationView.h"
#import "BBVoiceRecordToastContentView.h"
#import "BBVoiceRecordView.h"
#import "UIColor+BBVoiceRecord.h"
#import "UIImage+BBVoiceRecord.h"
#import "AvdioManager.h"
#import "XVIEWSDKObject.h"

FOUNDATION_EXPORT double XVIEWAvdioManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char XVIEWAvdioManagerVersionString[];

