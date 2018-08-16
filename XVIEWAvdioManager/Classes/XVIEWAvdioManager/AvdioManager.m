//
//  AvdioManager.m
//  AvdioManager
//
//  Created by yyj on 2018/7/11.
//  Copyright © 2018年 zd. All rights reserved.
//

#import "AvdioManager.h"
#import "AudioPlayerManager.h"
#import "AudioRecordView.h"
#import "AudioProcessManager.h"
#import "XVIEWSDKObject.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface AvdioManager()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,strong) void (^avCallBack) (XVIEWSDKResonseStatusCode code,NSDictionary *info);
@end
@implementation AvdioManager
+ (instancetype)defaultAvdioManager{
    static AvdioManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AvdioManager alloc]init];
    });
    return manager;
}
/*
 *  播放音频
 *  state 播放状态
 *  url   播放路径
 */
- (void)xviewPlayAudio:(NSDictionary *)dict avCallBack:(void(^)(XVIEWSDKResonseStatusCode code,NSDictionary* info))avCallback{
    AudioPlayerManager *player = [AudioPlayerManager defaultAudioPlayerManager];
    player.audioPlayerBlock = ^(NSDictionary *info) {
        avCallback(XVIEWSDKCodeSuccess,info);
    };
    if ([dict[@"state"] isEqualToString:@"play"]) {
        if ([dict[@"url"] hasPrefix:@"http"]) {
            [player.audioPlayer play:dict[@"url"]];
        } else {
            AudioProcessManager *manager = [AudioProcessManager defaultAudioProcessManager];
            manager.recorderPlayerBlock = ^(NSDictionary *info) {
                avCallback(XVIEWSDKCodeSuccess,info);
            };
            [manager playLocalAudio:dict[@"url"]];
            //            [manager playLocalAudio:[[NSBundle mainBundle] pathForResource:@"1111" ofType:@"caf"]];
        }
    } else if ([dict[@"state"] isEqualToString:@"stop"]) {
        if ([dict[@"url"] hasPrefix:@"http"]) {
            [player.audioPlayer stop];
        } else {
            AudioProcessManager *manager = [AudioProcessManager defaultAudioProcessManager];
            [manager resumePlay];
        }
    } else if ([dict[@"state"] isEqualToString:@"pause"]) {
        if ([dict[@"url"] hasPrefix:@"http"]) {
            [player pause];
        } else {
            AudioProcessManager *manager = [AudioProcessManager defaultAudioProcessManager];
            [manager resumePlay];
        }
    } else if ([dict[@"state"] isEqualToString:@"resume"]) {
        if ([dict[@"url"] hasPrefix:@"http"]) {
            [player.audioPlayer resume];
        } else {
            AudioProcessManager *manager = [AudioProcessManager defaultAudioProcessManager];
            [manager resumePlay];
        }
    }
}
/*
 *  录制音频
 *  currentVc 当前vc
 */
- (void)xviewRecordAudio:(NSDictionary *)dict avCallBack:(void(^)(XVIEWSDKResonseStatusCode code,NSDictionary* info))avCallback {
    //    __weak typeof(self) weakSelf = self;
    AudioRecordView *audioView = [[AudioRecordView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)  para:dict];
    __weak typeof(audioView) weakAudio = audioView;
    audioView.myRecordBlock = ^(NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakAudio removeFromSuperview];
        });
        avCallback(XVIEWSDKCodeSuccess,info);
    };
    UIViewController *vc = (UIViewController*)dict[@"currentVc"];
    [vc.view addSubview:audioView];
}
/*
 *  选择视频上传
 *  type      选择视频类型
 *  currentVc 当前vc
 */
- (void)xviewSelectVideoUpload:(NSDictionary *)dict avCallBack:(void(^)(XVIEWSDKResonseStatusCode code,NSDictionary* info))avCallback {
    // 1.判断相册是否可以打开
    self.avCallBack = avCallback;
    UIViewController *viewController = (UIViewController*)dict[@"currentVc"];
    NSString *type = dict[@"type"];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.view.frame = viewController.view.bounds;
    if ([type isEqualToString:@"cameraImage"]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes =  [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    } else if ([type isEqualToString:@"recorderVideo"]) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        picker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    } else if ([type isEqualToString:@"selectVideo"]) {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:picker animated:YES completion:nil];
    });
}
#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:^{
        NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
        //当选择的类型是图片
        if ([type isEqualToString:@"public.image"]) {
            [self getCompressImage:info[UIImagePickerControllerEditedImage]];
            
        }else if([type isEqualToString:@"public.movie"]){
            NSURL *inputUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            NSLog(@"videoPath->%@", inputUrl.absoluteString);
            NSString *outputStr = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/%@.mp4", [self getTimeyyyyMMdd]]];
            NSLog(@"outputStr->%@", outputStr);
            [self convertVideoQuailtyWithInputURL:inputUrl outputURL:[NSURL fileURLWithPath:outputStr] completeHandler:^(AVAssetExportSession *handler) {
                if (handler.status == AVAssetExportSessionStatusCompleted) {
                    NSString *movPath = [inputUrl.absoluteString substringFromIndex:7];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    if ([fileManager fileExistsAtPath:movPath]) {
                        NSError *error = nil;
                        [fileManager removeItemAtPath:movPath error:&error];
                        if (error) NSLog(@"error->%@", error);
                    }
                    NSLog(@"handler.outputFileType->%@-%f-%lld", handler.outputFileType, [self getVideoLength:[NSURL fileURLWithPath:outputStr]], [self fileSizeAtPath:outputStr]);
                    //获取缩略图, 如果缩略图获取失败, 则使用工程中默认图片
                    //缩略图路径 thumbPath = [outputStr stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"];
                    //mp4视频文件路径 outputStr;
                    BOOL haveThum = [self saveThumImageWithVideoPath:outputStr];
                    if (haveThum) {
                        NSLog(@"缩略图获取结果: success");
                        if (self.avCallBack) {
                            self.avCallBack(XVIEWSDKCodeSuccess,@{@"video": outputStr, @"image":[outputStr stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"]});
                        }
                    }
                    else {
                        NSLog(@"缩略图获取结果: fail");
                        if (self.avCallBack) {
                            self.avCallBack(XVIEWSDKCodeFail, @{@"video": outputStr, @"image":[outputStr stringByReplacingOccurrencesOfString:@"mp4" withString:@"png"]});
                        }
                    }
                }
                // 完成上传视频之后，删除outputStr文件
                else if (handler.status == AVAssetExportSessionStatusFailed) {
                    if (self.avCallBack) {
                        self.avCallBack(XVIEWSDKCodeFail,@{@"result": [NSString stringWithFormat:@"%@", handler.error]});
                    }
                } else {
                    if (self.avCallBack) {
                        self.avCallBack(XVIEWSDKCodeFail,@{@"result": [NSString stringWithFormat:@"%@", handler.error]});
                    }
                }
            }];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"取消");
    }];
}

- (void)convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                              outputURL:(NSURL*)outputURL
                        completeHandler:(void (^)(AVAssetExportSession*))handler {
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession= [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
        exportSession.outputURL = outputURL;
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"未知");
                    break;
                case AVAssetExportSessionStatusWaiting: break;
                case AVAssetExportSessionStatusExporting: break;
                case AVAssetExportSessionStatusCompleted: NSLog(@"完成"); break;
                case AVAssetExportSessionStatusFailed:    NSLog(@"失败"); break;
                case AVAssetExportSessionStatusCancelled: NSLog(@"取消"); break;
            }
            handler(exportSession);
        }];
    }
}

/**
 获取videoPath路径下视频文件的缩略图
 
 @param videoPath  视频路径
 @return  是否成功获取到缩略图
 */
- (BOOL)saveThumImageWithVideoPath:(NSString *)videoPath {
    AVURLAsset *urlSet = [AVURLAsset assetWithURL: [NSURL fileURLWithPath:videoPath]];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    
    CMTime time = CMTimeMake(1, 10);
    NSError *error = nil;
    CGImageRef cgimage = [imageGenerator copyCGImageAtTime:time actualTime:nil error:&error];
    if (error) {
        NSLog(@"缩略图获取失败!:%@",error);
        return NO;
    }
    UIImage *image = [UIImage imageWithCGImage:cgimage scale:0.6 orientation:UIImageOrientationUp];
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    NSString *thumPath = [videoPath stringByReplacingOccurrencesOfString:@"mp4" withString: @"png"];
    BOOL isok = [imgData writeToFile:thumPath atomically: YES];
    CGImageRelease(cgimage);
    return isok;
}

/**
 *返回时间戳
 */
- (NSString *)getTimeyyyyMMdd {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhhMMssSSS"];
    return [formatter stringFromDate:[NSDate date]];
}

//判断文件的大小
- (long long)fileSizeAtPath:(NSString*)filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
/**
 得到video视频长度
 
 @param URL 视频url
 @return 视频长度
 */
- (CGFloat)getVideoLength:(NSURL *)URL {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}
#pragma mark ==获取压缩的图片==
- (UIImage *)getCompressImage:(UIImage *)image {
    NSString *_nameString = @"www.png";
    NSData *data1;
    if (UIImagePNGRepresentation(image) == nil) data1 = UIImageJPEGRepresentation(image, 1);
    else                                        data1 = UIImagePNGRepresentation(image);
    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //把刚刚图片转换的data对象拷贝至沙盒中 并保存为image.png
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@", _nameString]] contents:data1 attributes:nil];
    //得到选择后沙盒中图片的完整路径
    NSString *filePath = [[NSString alloc]initWithFormat:@"%@/%@",DocumentsPath, _nameString];
    NSLog(@"print file-->%@",filePath);
    
    long long abc = [self fileSizeAtPath:filePath];
    
    if (abc < 1024000) {
        return image;
    }
    else {
        UIImage *small = [self imageWithImageSimple:image scaledToSize:CGSizeMake(image.size.width/4, image.size.height/4)];
        NSData *data;
        if (UIImagePNGRepresentation(small) == nil) {
            data = UIImageJPEGRepresentation(small, 1);
        }
        else {
            data = UIImagePNGRepresentation(small);
        }
        //沙盒中图片的完整路径
        NSString *string1 = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@", _nameString]];
        NSFileManager *fileManage = [NSFileManager defaultManager];
        [fileManage removeItemAtPath:string1 error:nil];
        [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:[NSString stringWithFormat:@"/%@", _nameString]] contents:data attributes:nil];
        return small;
    }
}
//压缩图片
- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize {
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}

@end
