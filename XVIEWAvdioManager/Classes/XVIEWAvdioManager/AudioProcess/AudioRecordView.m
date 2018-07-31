//
//  AudioRecordView.m
//  XVIEWApp
//
//  Created by nanjingxiaheng on 2017/11/13.
//  Copyright © 2017年 Lianghao An. All rights reserved.
//

#import "AudioRecordView.h"
#import "AudioProcessManager.h"

#import "BBVoiceRecordController.h"
#import "UIColor+BBVoiceRecord.h"
#import "BBHoldToSpeakButton.h"

#define kFakeTimerDuration       0.5
//#define kMaxRecordDuration       60
#define kRemainCountingDuration  3     //剩余多少秒开始倒计时

#define CloseBtn       @"关闭录音"
@interface AudioRecordView()

@property (nonatomic, strong) BBVoiceRecordController *voiceRecordCtrl;
@property (nonatomic, strong) BBHoldToSpeakButton     *btnRecord;
@property (nonatomic, strong) UIButton                *closeBtn;
@property (nonatomic, assign) BBVoiceRecordState       currentRecordState;
@property (nonatomic, strong) NSTimer                 *fakeTimer;
@property (nonatomic, assign) float                    duration;
@property (nonatomic, assign) BOOL                     canceled;
@property (nonatomic, strong) AudioProcessManager     *recordManager;
@property (nonatomic, assign) NSInteger               kMaxRecordDuration;  //最长录音时长
@property (nonatomic, strong) NSDictionary            *callbackPara; //回调参数

@end

@implementation AudioRecordView

- (instancetype)initWithFrame:(CGRect)frame  para:(NSDictionary *)jsPara {
//                     callback:(RecordBlock)recordBlock
    if (self = [super initWithFrame:frame]) {
        if (jsPara[@"time"] == nil || [jsPara[@"time"] integerValue] == 0) {
            _kMaxRecordDuration = 1111;
        } else {
            NSInteger time = [jsPara[@"time"] integerValue];
            _kMaxRecordDuration = time > 0 ? time : 60;
        }
//        self.myRecordBlock = recordBlock;
        self.backgroundColor = [UIColor grayColor];
        self.alpha = 0.9;
        
        _btnRecord = [BBHoldToSpeakButton buttonWithType:UIButtonTypeCustom];
        _btnRecord.frame = CGRectMake(10, Screen_Height - 120, Screen_Width - 20, 50);
        _btnRecord.layer.borderWidth = 0.5;
        _btnRecord.layer.borderColor = [UIColor colorWithHex:0xA3A5AB].CGColor;
        _btnRecord.layer.cornerRadius = 4;
        _btnRecord.layer.masksToBounds = YES;
        _btnRecord.enabled = NO;    //将事件往上传递
        _btnRecord.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_btnRecord setTitleColor:[UIColor colorWithHex:0x565656] forState:UIControlStateNormal];
        [_btnRecord setTitleColor:[UIColor colorWithHex:0x565656] forState:UIControlStateHighlighted];
        [_btnRecord setTitle:LongBtn forState:UIControlStateNormal];
        _btnRecord.backgroundColor = [UIColor whiteColor];
        _btnRecord.alpha = 1.0;
        [self addSubview:_btnRecord];
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectMake(10, Screen_Height - 60, Screen_Width - 20, 50);
        _closeBtn.layer.borderWidth = 0.5;
        _closeBtn.layer.borderColor = [UIColor colorWithHex:0xA3A5AB].CGColor;
        _closeBtn.layer.cornerRadius = 4;
        _closeBtn.layer.masksToBounds = YES;
        _closeBtn.enabled = NO;    //将事件往上传递
        _closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_closeBtn setTitle:CloseBtn forState:UIControlStateNormal];
        _closeBtn.backgroundColor = [UIColor colorWithHex:0xffc529];
        _closeBtn.alpha = 1.0;
        [self addSubview:_closeBtn];
        [_closeBtn addTarget:self action:@selector(closeRecord) forControlEvents:UIControlEventTouchUpInside];
        
        _callbackPara = @{@"code":@"-1", @"message":@"未录制音频"};
        __weak typeof(self) weakSelf = self;
        _recordManager = [AudioProcessManager defaultAudioProcessManager];
        _recordManager.recorderPlayerBlock = ^(NSDictionary *callback) {
            DLog(@"calback->%@", callback);
            weakSelf.callbackPara = callback;
            if ([weakSelf.callbackPara[@"code"] isEqual:@"0"]) {
                if (weakSelf.myRecordBlock) {
                    weakSelf.myRecordBlock(callback);
                }
            }
        };
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) { }
    return self;
}

- (void)closeRecord {
    if (self.myRecordBlock) {
        self.myRecordBlock(_callbackPara);
    }
}

- (void)startFakeTimer {
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
    self.fakeTimer = [NSTimer scheduledTimerWithTimeInterval:kFakeTimerDuration target:self selector:@selector(onFakeTimerTimeOut) userInfo:nil repeats:YES];
    [_fakeTimer fire];
}

- (void)stopFakeTimer {
    if (_fakeTimer) {
        [_fakeTimer invalidate];
        _fakeTimer = nil;
    }
}

- (void)onFakeTimerTimeOut {
    self.duration += kFakeTimerDuration;
//    NSLog(@"+++duration+++ %f",self.duration);
    float remainTime = _kMaxRecordDuration - self.duration;
    if ((int)remainTime == 0) {
        self.currentRecordState = BBVoiceRecordState_Normal;
        [self dispatchVoiceState];
    }
    else if ([self shouldShowCounting]) {
        self.currentRecordState = BBVoiceRecordState_RecordCounting;
        [self dispatchVoiceState];
        [self.voiceRecordCtrl showRecordCounting:remainTime];
    }
    else {
        float fakePower = (float)(1+arc4random()%99)/100;
//        float fakePower = [_recordManager updateMeters];
        [self.voiceRecordCtrl updatePower:fakePower];
    }
}

- (BOOL)shouldShowCounting {
    if (self.duration >= (_kMaxRecordDuration - kRemainCountingDuration) && self.duration < _kMaxRecordDuration && self.currentRecordState != BBVoiceRecordState_ReleaseToCancel) {
        return YES;
    }
    return NO;
}

- (void)resetState {
    [self stopFakeTimer];
    self.duration = 0;
    self.canceled = YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_btnRecord.frame, touchPoint)) {
        [_recordManager startRecord];
        self.currentRecordState = BBVoiceRecordState_Recording;
        [self dispatchVoiceState];
    } else if (CGRectContainsPoint(_closeBtn.frame, touchPoint)) {
        [self closeRecord];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_canceled) return;
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_btnRecord.frame, touchPoint)) {
        self.currentRecordState = BBVoiceRecordState_Recording;
    }
    else {
        self.currentRecordState = BBVoiceRecordState_ReleaseToCancel;
    }
    [self dispatchVoiceState];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_canceled) return;
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_btnRecord.frame, touchPoint)) {
        if (self.duration < 3) {
            [self.voiceRecordCtrl showToast:@"录制时间太短"];
            [_recordManager cancleRecord];
        }
        else {
            //upload voice
            [_recordManager stopRecord];
        }
    }
    self.currentRecordState = BBVoiceRecordState_Normal;
    [self dispatchVoiceState];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_canceled) return;
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(_btnRecord.frame, touchPoint)) {
        if (self.duration < 3) {
            [self.voiceRecordCtrl showToast:@"录制时间太短"];
            [_recordManager cancleRecord];
        }
        else {
            //upload voice
            [_recordManager cancleRecord];
        }
    } else {
        if ([_recordManager isRecorder]) {
            
        }
    }
    self.currentRecordState = BBVoiceRecordState_Normal;
    [self dispatchVoiceState];
}

- (void)dispatchVoiceState {
    if (_currentRecordState == BBVoiceRecordState_Recording) {
        self.canceled = NO;
        [self startFakeTimer];
    } else if (_currentRecordState == BBVoiceRecordState_Normal) {
        if ([_recordManager isRecorder]) {
            [_recordManager cancleRecord];
        }
        [self resetState];
    }
    [_btnRecord updateRecordButtonStyle:_currentRecordState];
    [self.voiceRecordCtrl updateUIWithRecordState:_currentRecordState];
}

- (BBVoiceRecordController *)voiceRecordCtrl {
    if (_voiceRecordCtrl == nil) {
        _voiceRecordCtrl = [BBVoiceRecordController new];
    }
    return _voiceRecordCtrl;
}




@end
