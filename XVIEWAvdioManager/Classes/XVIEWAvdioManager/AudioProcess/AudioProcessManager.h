//
//  AudioRecorderManager.h
//  XView1.0
//
//  Created by 南京夏恒 on 16/8/2.
//  Copyright © 2016年 南京夏恒. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <UIKit/UIKit.h>
//录音、播放本地音频
@interface AudioProcessManager : NSObject

@property (nonatomic, strong) AVAudioRecorder *audioRecorder; //音频录音机
@property (nonatomic, copy)   NSString            *uploadUrl; //上传音频文件网址
@property (nonatomic, strong) NSDictionary        *uploadPara;  //上传音频文件时所带参数
/**
 *  单例类
 *
 *  @return 您可以通过此方法，获取AudioProcessManager的单例，访问对象中的属性和方法
 */
+ (instancetype)defaultAudioProcessManager;

/**
 判断是否正在录音

 @return 是否正在录音
 */
- (BOOL)isRecorder;


/**
 开始录音
 */
- (void)startRecord;
/**
 *  点击暂定按钮
 *  param sender 暂停按钮
 */
- (void)pauseRecord;

/**
 *  点击恢复按钮
 *  恢复录音只需要再次调用record，AVAudioSession会帮助你记录上次录音位置并追加录音
 *
 */
- (void)resumeRecord;

/**
 *  点击停止按钮
 */
- (void)stopRecord;

/**
 取消录制音频
 */
- (void)cancleRecord;
/**
 更新音量
 
 @return 返回当前音量
 */
- (CGFloat) updateMeters;

/**
 *   播放本地音频文件
 *
 *  @param pathString 本地文件的路径
 */
- (void)playLocalAudio:(NSString *)pathString;
- (void)pausePlay;
- (void)resumePlay;
- (void)stopPlay;

/**
 *  录制播放音频视频类的回调block
 */
@property (nonatomic, copy) void (^recorderPlayerBlock) (NSDictionary *callback);

@end
