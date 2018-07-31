//
//  AudioPlayerManager.h
//  XView1.0
//
//  Created by 南京夏恒 on 16/8/2.
//  Copyright © 2016年 南京夏恒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"
//播放网络音频
@interface AudioPlayerManager : NSObject
/**
 *  单例类
 *
 *  @return 您可以通过此方法，获取AudioPlayerManager的单例，访问对象中的属性和方法
 */
+ (instancetype)defaultAudioPlayerManager;

/**
 *  播放网络音频
 *
 *  @param path 音频网址
 */
- (void)playerNetworkAudio:(NSString *)path;

/**
 *  停止播放本地音频
 */
- (void)stop;

/**
 暂停播放音频
 */
- (void)pause;

/**
 继续播放上一段音频
 */
- (void)resume;

/**
 *  播放音频视频类的回调block
 */
@property (nonatomic, copy) void (^audioPlayerBlock) (NSDictionary *callback);

@property (nonatomic, strong) STKAudioPlayer            *audioPlayer;
@end
