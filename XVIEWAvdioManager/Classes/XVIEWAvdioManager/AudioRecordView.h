//
//  AudioRecordView.h
//  XVIEWApp
//
//  Created by nanjingxiaheng on 2019/1/7.
//  Copyright © 2019年 ZD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^RecordBlock) (NSDictionary *dict);

@interface AudioRecordView : UIView

@property (nonatomic, copy) RecordBlock    myRecordBlock;

/**
 初始化 录音界面

 @param frame 界面frame
 @param jsPara 交互参数，注意处理{"time": "录音最大时长(单位：秒),默认60秒,0无限制"}
 @return 录音界面
 */
- (instancetype)initWithFrame:(CGRect)frame para:(NSDictionary *)jsPara;

@end
