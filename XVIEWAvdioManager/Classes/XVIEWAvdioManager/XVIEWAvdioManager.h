//
//  XVIEWAvdioManager.h
//  XVIEWAvdioManager
//
//  Created by yyj on 2019/1/7.
//  Copyright © 2019 zd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XVIEWAvdioManager : NSObject

/**
 *  单例
 */
+ (instancetype)sharedAvdioManager;

/**
 *  播放录音
 @param param   data:{"url":播放路径}
                callback:回调方法
 */
- (void)play:(NSDictionary *)param;

/**
 *  继续播放
 @param param   callback:回调方法
 */
- (void)resume:(NSDictionary *)param;

/**
 *  暂停播放
 @param param   callback:回调方法
 */
- (void)pause:(NSDictionary *)param;

/**
 *  停止播放
 @param param   callback:回调方法
 */
- (void)stop:(NSDictionary *)param;

/**
 *  录制音频
 @param param   currentVC:当前vc
                callback:回调方法
 */
- (void)record:(NSDictionary *)param;

@end
