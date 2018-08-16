//
//  XVIEWSDKObject.h
//  XVIEW2.0
//
//  Created by njxh on 16/12/14.
//  Copyright © 2016年 南京 夏恒. All rights reserved.
//

#ifndef XVIEWSDKObject_h
#define XVIEWSDKObject_h

typedef NS_ENUM(NSInteger, XVIEWSDKResonseStatusCode)
{
    XVIEWSDKCodeSuccess                = 0,       //成功
    XVIEWSDKCodeFail                   = 1,       //失败
    XVIEWSDKCodeError                  = 2,       //错误
};

typedef NS_ENUM(NSInteger, XVIEWSDKPlatfromType)
{
    
    XVIEWPlatformMap                           =         13,       //地图
    
    XVIEWPlatformChat                          =         14,       //聊天
    
    XVIEWPlatformPush                          =         15,       //推送
};

#endif /* XVIEWSDKObject_h */
