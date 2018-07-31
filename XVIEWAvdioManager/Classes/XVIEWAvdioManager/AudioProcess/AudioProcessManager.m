//
//  AudioRecorderManager.m
//  XView1.0
//
//  Created by 南京夏恒 on 16/8/2.
//  Copyright © 2016年 南京夏恒. All rights reserved.
//
#define kRecordAudioFile @"myRecord.wav"

#import "AudioProcessManager.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "lame.h"


@interface AudioProcessManager () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, copy)   NSString            *nameString;  //音频名称（录制）
@property (nonatomic, copy)   NSString            *playString;  //音频名称（播放）
@property (nonatomic, copy)   NSString            *mp3Url;      //上传文件路径
@property (nonatomic, strong) AVAudioPlayer       *audioPlayer; //播放器
@property (nonatomic, strong) UIView              *recordView;


@end
@implementation AudioProcessManager {
    UIButton *cancelBtn;
    UIButton *playBtn;
    UIButton *completeBtn;
    BOOL     cancelOrComplete;
    
    NSTimer *_showTimer;
    NSInteger showTime;//展示时间
    UILabel *showTimeLabel; //展示时间label
    
    AVAudioSession *_audioSession;
}

/**
 *  单例类
 *
 *  @return 您可以通过此方法，获取AudioProcessManager的单例，访问对象中的属性和方法
 */
+ (instancetype)defaultAudioProcessManager {
    static AudioProcessManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[AudioProcessManager alloc] init];
    });
    return _instance;
}
- (instancetype)init {
    if (self = [super init]) {
#pragma mark ================== 添加检测app进入后台的观察者 ========================
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
- (void)applicationEnterBackground {
    if (_recordView) {
        if ([self.audioRecorder isRecording])  [self.audioRecorder stop];
        else if ([self.audioPlayer isPlaying]) [self.audioPlayer stop];
    }
}
/**
 *  取得录音文件保存路径
 *
 *  @return 录音文件路径
 */
-(NSURL *)getSavePath:(NSString *)name {
    NSURL *url=[NSURL fileURLWithPath:[self getSaveUrlPath:name]];
    return url;
}
- (NSString *)getSaveUrlPath:(NSString *)name {
    NSString *getSaveUrlPath = [self documentsPath];
    getSaveUrlPath = [getSaveUrlPath stringByAppendingPathComponent:name];
    return getSaveUrlPath;
}
- (NSString *)documentsPath {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSString *pathStr = [NSString stringWithFormat:@"%@.wav", [self getTimeyyyyMMdd]];
        _nameString = pathStr;
        NSURL *_pathUrl = [self getSavePath: pathStr];
        NSDictionary *setting = [self getAudioSetting];
        NSError *error=nil;
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:_pathUrl settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=NO;//如果要监控声波则必须设置为YES
        
        // 设置音频会话
        _audioSession = [AVAudioSession sharedInstance];
        [self setAudioSession:AVAudioSessionCategoryPlayAndRecord];
        if (error) {
            if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"data":@{@"result":[NSString stringWithFormat:@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription]}, @"message":@"创建录音机对象时发生错误", @"code":@"-1"});
            return nil;
        }
    }
    return _audioRecorder;
}
/**
 *  录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting {
    NSMutableDictionary *recordSettings=[NSMutableDictionary dictionary];
    //录音格式 无法使用
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    [recordSettings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//采样率 44100.0
    [recordSettings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];//通道数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey]; //线性采样位数
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];//音频质量,采样质量
    //....其他设置等
    return recordSettings;
}

/**
 *返回时间戳
 */
- (NSString *)getTimeyyyyMMdd {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhhMMssSSS"];
    return [NSString stringWithFormat:@"%@", [formatter stringFromDate:[NSDate date]]];
}


/**
 是否正在录制音频

 @return 是否正在录制音频
 */
- (BOOL)isRecorder {
    if ([self.audioRecorder isRecording]) return YES;
    else return NO;
}
/**
 开始录音
 */
- (void)startRecord {
    cancelOrComplete = YES;
    [self.audioRecorder record];
}
/**
 *  点击暂定“录制”按钮
 */
- (void)pauseRecord {
    if ([self.audioRecorder isRecording])
        [self.audioRecorder pause];
}
/**
 *  点击恢复按钮
 *  恢复录音只需要再次调用record，AVAudioSession会帮助你记录上次录音位置并追加录音
 */
- (void)resumeRecord {
    if (![self.audioRecorder isRecording])
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
}
/**
 *  点击停止“录制”按钮
 */
- (void)stopRecord {
    [self.audioRecorder stop];
}
/**
 取消录制音频
 */
- (void)cancleRecord {
    cancelOrComplete = NO;
    [self.audioRecorder stop];
}


/**
 更新音量

 @return 返回当前音量
 */
- (CGFloat)updateMeters {
    if ([self.audioRecorder isRecording]) {
        [self.audioRecorder updateMeters];
        NSLog(@"%lf-%lf", [self _normalizedPowerLevelFromDecibels:[self.audioRecorder averagePowerForChannel:0]], [self.audioRecorder averagePowerForChannel:0]);
        return [self _normalizedPowerLevelFromDecibels:[self.audioRecorder averagePowerForChannel:0]];
    } else {
        return 0;
    }
}
#pragma mark - Private
- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels {
    if (decibels < -60.0f || decibels == 0.0f) return 0.0f;
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
//    return (float)(decibels)/100;
}
#pragma mark - 录音机代理方法
/**
 *  录音完成，录音完成后播放录音
 *
 *  @param recorder 录音机对象
 *  @param flag     是否成功
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if (!cancelOrComplete) {
        if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"message":@"取消录音", @"code":@"-1"});
        return;
    }
    [_audioPlayer play];
    NSString *mp3Url = [self getSaveUrlPath:_nameString];
    /*
     真机转码[cafUrl cStringUsingEncoding:1]为nil直接闪退，因此直接使用wav格式，原为caf
   */
//    NSString *mp3Url = [self audio_PCMtoMP3:[self getSaveUrlPath:_nameString]];
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:mp3Url]){
            self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:mp3Url] error:nil];
        if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"data":@{@"time":[NSString stringWithFormat:@"%.2f",self.audioPlayer.duration], @"file_path_audio": mp3Url}, @"message":@"录音完成", @"code":@"0"});
      /*
       由于时间获取的不准，更改为self.audioPlayer.duration
    */
//            if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"data":@{@"time":[NSString stringWithFormat:@"%02f", [self audioSoundDuration:[NSURL URLWithString:mp3Url]]], @"file_path_audio": mp3Url}, @"message":@"录音完成", @"code":@"0"});
    } else {
        if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"message":@"录音转码失败!", @"code":@"-1"});
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_recordView)
                [_recordView removeFromSuperview];
        });
    }
}
/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur-> %@", error.localizedDescription);
}
#pragma mark ================== caf转mp3格式 ========================
- (NSString *)audio_PCMtoMP3:(NSString *)cafUrl {
    _mp3Url = [NSString stringWithFormat:@"%@/%@.mp3", [self documentsPath], [self getTimeyyyyMMdd]];
    @try {
        int read, write;
        FILE *pcm = fopen([cafUrl cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([_mp3Url cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            fwrite(mp3_buffer, write, 1, mp3);
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"exception->%@",[exception description]);
        return _mp3Url;
    }
    @finally {
        return _mp3Url;
    }
}
#pragma mark ================== 录音文件时长统计 ========================
- (float)audioSoundDuration:(NSURL *)fileUrl{
    NSDictionary *options = @{AVURLAssetPreferPreciseDurationAndTimingKey: @YES};
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:fileUrl options:options];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}

//单个文件的大小
- (long long)fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    } else {
        NSLog(@"fileSizeAtPath==计算文件大小：文件不存在");
    }
    return 0;
}

/**
 *   播放本地音频文件
 *
 *  @param pathString 本地文件的路径
 */
-(void)playLocalAudio:(NSString *)pathString {
    _playString = pathString;
    [self.audioPlayer play];
}
- (void)pausePlay {
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
    }
}
- (void)resumePlay {
    if (![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
    }
}
- (void)stopPlay {
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
    }
}
#pragma mark - 播放器
/** audioPlayer 创建(懒加载) */
- (AVAudioPlayer *)audioPlayer {
    if (!_audioPlayer) {
        NSError *error;
        if (_playString == nil || _playString.length == 0) {
            if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"code":@"-1", @"data":@{@"result":@"音频路径错误"}, @"message":@"音频路径错误"});
            return nil;
        }
        
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[self getAudioPathUrl:_playString] error:nil];
        if (error) {
            if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"code":@"-1", @"data":@{@"result":[NSString stringWithFormat:@"播放器创建失败: %@", error.localizedDescription]}, @"message":@"播放器创建失败"});
        }
        [self setAudioSession:AVAudioSessionCategoryPlayback];
        _audioPlayer.delegate = self;
        _audioPlayer.numberOfLoops = 0; // 设置播放属性，不循环
        [_audioPlayer prepareToPlay];   // 准备播放，加载音频文件到缓存
    }
    return _audioPlayer;
}
- (NSURL *)getAudioPathUrl:(NSString *)path {
    if ([path componentsSeparatedByString:@"/"].count > 3) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return [NSURL URLWithString:path];
        } else {
            if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"code":@"-1", @"data":@{@"result":@"音频路径不存在"}, @"message":@"音频路径不存在"});
            return nil;
        }
    }
    return [self getSavePath:path];
}
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self audioPlayEnd:@"播放完成"];
}
/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"code":@"-1", @"data":@{@"result":[NSString stringWithFormat:@"audioPlayerDecodeErrorDidOccur: %@", error.localizedDescription]}, @"message":@"fail"});
    self.audioPlayer = nil;
}
#pragma mark ================== 播放结束操作 ========================
- (void)audioPlayEnd:(NSString *)title {
    if (self.recorderPlayerBlock) self.recorderPlayerBlock(@{@"code":@"0", @"data":@{@"result":@"播放结束"}, @"message":@"播放结束"});
    self.audioPlayer = nil;
}

/**
 *  设置音频会话
 */
-(void)setAudioSession:(NSString *)category {
    if (_audioSession) {
        [_audioSession setCategory:category error:nil];
        [_audioSession setActive:YES error:nil];
    } else {
        _audioSession = [AVAudioSession sharedInstance];
        //默认情况下扬声器播放
        [_audioSession setCategory:category error:nil];
        [_audioSession setActive:YES error:nil];
    }
}

/**
 获取XVIEWFunction.bundle内image路径

 @param imageName image名字
 @return image路径
 */
- (NSString *)imagePath:(NSString *)imageName {
    NSString *bundleString = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"XVIEWFunction.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundleString];
    return [bundle pathForResource:imageName ofType:@""];
}

@end
