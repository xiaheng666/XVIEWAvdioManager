
//
//  AudioPlayerManager.m
//  XView1.0
//
//  Created by 南京夏恒 on 16/8/2.
//  Copyright © 2016年 南京夏恒. All rights reserved.
//
#define kRecordAudioFile @"myRecord.wav"

#import "AudioPlayerManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "STKAudioPlayer.h"
@interface AudioPlayerManager () <STKAudioPlayerDelegate>

@end
@implementation AudioPlayerManager

/**
 *  单例类
 *
 *  @return 您可以通过此方法，获取AudioPlayerManager的单例，访问对象中的属性和方法
 */
+ (instancetype)defaultAudioPlayerManager {
    static AudioPlayerManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AudioPlayerManager alloc] init];
        [_instance setAudioSession];
    });
    return _instance;
}
#pragma mark ================== STKAudioPlayerDelegate method ========================
- (void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    if (errorCode) {
        if (self.audioPlayerBlock) self.audioPlayerBlock(@{@"code":@"-1", @"data":@{@"result":[NSString stringWithFormat:@"STKAudioPlayerErrorCode-%ld",errorCode]}, @"message":[NSString stringWithFormat:@"STKAudioPlayerErrorCode-%ld",errorCode]});
    }
}
- (void)audioPlayer:(STKAudioPlayer *)audioPlayer didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
    if (self.audioPlayerBlock) self.audioPlayerBlock(@{@"code":@"0", @"data":@{@"result":@"playEnd"}, @"message":@"playEnd"});
}
- (void)audioPlayer:(STKAudioPlayer *)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
//    if (state == STKAudioPlayerStateError || state == STKAudioPlayerStateDisposed || state == STKAudioPlayerStateBuffering ) {
//        if (self.audioPlayerBlock) self.audioPlayerBlock(@{@"code":@"01", @"description":[NSString stringWithFormat:@"STKAudioPlayerState-%ld",state]});
//    }
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
    
}
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {
    
}
/**
 *  设置音频会话
 */
-(void)setAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
}
- (STKAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        _audioPlayer = [[STKAudioPlayer alloc] init];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}
/**
 *   播放本地音频文件
 *
 *  @param pathString 本地文件的路径
 */
-(void)playLocalAudio:(NSString *)pathString {
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathString]) {
        NSURL *url=[NSURL fileURLWithPath:pathString];
        [self.audioPlayer playURL:url];
    }
    else {
        NSLog(@"音频文件不存在");
    }
    
}


/**
 *  播放网络音频
 *
 *  @param path 音频网址
 */
- (void)playerNetworkAudio:(NSString *)path {
    NSURL *url=[NSURL fileURLWithPath:path];
    [self.audioPlayer playURL:url];
}

/**
 *  停止播放本地音频
 */
- (void)stop {
    [self.audioPlayer stop];
}

/**
 暂停播放音频
 */
- (void)pause {
    [self.audioPlayer pause];
}

/**
 继续播放上一段音频
 */
- (void)resume {
    [self.audioPlayer resume];
}

@end
