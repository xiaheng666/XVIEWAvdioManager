//
//  AudioRecordView.h
//  XVIEWApp
//
//  Created by nanjingxiaheng on 2017/11/13.
//  Copyright © 2017年 Lianghao An. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^RecordBlock) (NSDictionary *callback);
@interface AudioRecordView : UIView

/**
 初始化 录音界面

 @param frame 界面frame
 @param jsPara 交互参数，注意处理{"time": "录音最大时长(单位：秒),默认60秒,0无限制"}
 @param recordBlock 回调参数
 @return 录音界面
 */
- (instancetype)initWithFrame:(CGRect)frame para:(NSDictionary *)jsPara;
//- (instancetype)initWithFrame:(CGRect)frame para:(NSDictionary *)jsPara callback:(RecordBlock)recordBlock;
@property (nonatomic, copy) RecordBlock    myRecordBlock;
@end
