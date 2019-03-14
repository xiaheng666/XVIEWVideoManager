//
//  WXShootingVContro.m
//  WeChart
//
//  Created by lk06 on 2018/4/26.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import "WXShootingVContro.h"
#import "ShootingToolBar.h"
#import "WXPlayerContro.h"
#define WIDTH_SCREEN        [UIScreen mainScreen].bounds.size.width
#define HEIGHT_SCREEN       [UIScreen mainScreen].bounds.size.height
#define IS_IPHONE_X ((IS_IPHONE && HEIGHT_SCREEN == 812.0)? YES : NO)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define NavHFit          (IS_IPHONE_X ? 88 : 64)

#define weakSelf(x)      typeof(x) __weak weakSelf = x
#define BottomYFit       (IS_IPHONE_X ? 43 : 0)

//录制视频及拍照分辨率
typedef NS_ENUM(NSUInteger, CaptureSessionPreset) {
    CaptureSessionPreset325x288,
    CaptureSessionPreset640x480,
    CaptureSessionPreset1280x720,
    CaptureSessionPreset1920x1080,
    CaptureSessionPreset3840x2160,
};

@interface WXShootingVContro ()<shootingToolBarDelegate,AVCaptureFileOutputRecordingDelegate>
//关闭页面按钮
@property (nonatomic , strong) UIButton * colseButton;
//切换摄像头按钮
@property (nonatomic , strong) UIButton * switchButton;
//拍摄条
@property (nonatomic , strong) ShootingToolBar * toolBar;
//播放VC
@property (nonatomic , strong) WXPlayerContro * palyerVc;
//显示视频的内容
@property (nonatomic , strong) UIView * userCamera;
//负责输入和输出设置之间的数据传递
@property (strong,nonatomic)   AVCaptureSession *captureSession;
//负责从AVCaptureDevice获得输入数据
@property (strong,nonatomic)   AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, assign) CaptureSessionPreset sessionPreset;
//照片输出流
@property (strong,nonatomic) AVCaptureStillImageOutput *captureStillImageOutput;
//视频输出流
@property (strong,nonatomic)   AVCaptureMovieFileOutput *captureMovieFileOutput;
//相机拍摄预览图层
@property (strong,nonatomic)   AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
//后台任务标示符
@property (nonatomic, assign)  UIBackgroundTaskIdentifier backgroundTaskIdentifier;
//保存的Url
@property (nonatomic, strong)  NSURL * localMovieUrl;
//拍照的照片
@property (nonatomic, strong)UIImage * image;
@end

@implementation WXShootingVContro

/**
 关闭按钮

 @return UIButton
 */
-(UIButton*)colseButton
{
    if (!_colseButton) {
        _colseButton = [[UIButton alloc]init];
        _colseButton.frame = CGRectMake(10 , 20, 40, 40);
        [_colseButton setImage:[UIImage imageNamed:@"close"] forState:normal];
        _colseButton.tag = 3;
        [_colseButton addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _colseButton;
}

/**
 切换摄像头按钮
 
 @return UIButton
 */
-(UIButton*)switchButton
{
    if (!_switchButton) {
        _switchButton = [[UIButton alloc]init];
        _switchButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 50 , 20, 40, 40);
        [_switchButton setImage:[UIImage imageNamed:@"switch"] forState:normal];
        [_switchButton addTarget:self action:@selector(btnToggleCameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}

- (void)closeClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (!granted) {
                    [self closeClick:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActive) name:UIApplicationWillResignActiveNotification object:nil];
                }
            }];
        } else {
            [self closeClick:nil];
        }
    }];
    
    //暂停其他音乐，
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)willResignActive
{
    if ([self.captureSession isRunning]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/**
 设置子控件
 */
-(void)setupSubViews
{
    [self.view addSubview:self.userCamera];
    [self.view addSubview:self.switchButton];
    [self.view addSubview:self.colseButton];
    [self.view addSubview:self.toolBar];
    [self addChildViewController:self.palyerVc];
    
    [self seingUserCamera];
 
}
/**
 *  捕获区域改变
 *
 *  @param notification 通知对象
 */
-(void)areaChange:(NSNotification *)notification{
    NSLog(@"捕获区域改变...");
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.captureSession startRunning];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}

#pragma --------------ShootingToolBar的代理方法-----------------start---
-(void)shooingStart:(ShootingToolBar *)toolBar actionType:(ActionType)type progress:(CGFloat)value
{
    
    if (type==Photo) {
        NSLog(@"拍照开始");
    }
    else{
        [self startRecordVideo];
    }
    
    
}
-(void)shootingStop:(ShootingToolBar *)toolBar shootingType:(ActionType)type
{
    //取出播放视图
    WXPlayerContro * vc = self.childViewControllers[0];
   [self.view insertSubview:vc.view aboveSubview:self.userCamera];
    if (type == Photo) {
        NSLog(@"拍照结束");
//        [self takePhoto:vc];
    }else{
//        NSLog(@"视频结束");
        [self stopRecordVideo];
        vc.url = self.localMovieUrl;
    }
}

- (void)shootingToolBarAction:(ShootingToolBar *)toolBar buttonIndex:(NSInteger)index { 
    if (index==1) {//重新拍摄
        [self.captureSession startRunning];
        [self.palyerVc removeSubViews];
        [self.palyerVc.player pause];
    }
    if (index==4) {
        if (self.recordBlock) {
            self.recordBlock(@{
                               @"videoPath":self.localMovieUrl.absoluteString,
//                               @"imagePrefix":@"data:image/png;base64,",
//                               @"imageBase64":
//                                   [self image2DataURL:[self videoHandlePhoto:self.localMovieUrl]]
                               });
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark ----------------ShootingToolBar-----------------------end---


#pragma mark ------AVCaptureFileOutputRecordingDelegate 实现代理-------statr------

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
//    NSLog(@"开始录制");
    self.colseButton.hidden  = YES;
    self.switchButton.hidden = YES;
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    
//    NSLog(@"完成录制");
    self.colseButton.hidden  = NO;
    self.switchButton.hidden = NO;
    
}
#pragma mark ------AVCaptureFileOutputRecordingDelegate 实现代理-------end------


/**
 用来显示录像内容
 
 @return UIView
 */
-(UIView*)userCamera
{
    if (!_userCamera) {
        _userCamera = [[UIView alloc]initWithFrame:self.view.bounds];
        _userCamera.backgroundColor = [UIColor blackColor];
        
    }
    return _userCamera;
}

-(void)seingUserCamera
{
    //初始化会话
    _captureSession=[[AVCaptureSession alloc]init];

    self.captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:[self backCamera] error:nil];
    //获得输入设备
//    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];//取得后置摄像头
//    if (!captureDevice) {
//        NSLog(@"取得后置摄像头时出现问题.");
//        return;
//    }
    //根据输入设备初始化设备输入对象，用于获得输入数据
    //    _captureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    //    if (error) {
    //        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
    //        return;
    //    }
    //添加一个音频输入设备
    
    
    AVCaptureDevice *audioCaptureDevice= [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    
    NSError *error=nil;
    AVCaptureDeviceInput *audioCaptureDeviceInput=[[AVCaptureDeviceInput alloc]initWithDevice:audioCaptureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    //视频输出流
    //设置视频格式
    self.sessionPreset = CaptureSessionPreset1280x720;
    NSString *preset = [self transformSessionPreset];
    if ([self.captureSession canSetSessionPreset:preset]) {
        self.captureSession.sessionPreset = preset;
    } else {
        self.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }

    //初始化设备输出对象，用于获得输出数据
    _captureMovieFileOutput=[[AVCaptureMovieFileOutput alloc]init];
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addInput:audioCaptureDeviceInput];
        AVCaptureConnection *captureConnection=[_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoStabilizationSupported ]) {
            captureConnection.preferredVideoStabilizationMode=AVCaptureVideoStabilizationModeAuto;
        }
    }
    
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
    }
   /*-----------*/
    //照片输出
     _captureStillImageOutput=[[AVCaptureStillImageOutput alloc]init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_captureStillImageOutput setOutputSettings:outputSettings];//输出设置
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    /*-----------*/
    
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    
    CALayer *layer=self.userCamera.layer;
    layer.masksToBounds=YES;
    
    _captureVideoPreviewLayer.frame=layer.bounds;
    [layer setMasksToBounds:YES];
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    //将视频预览层添加到界面中
    [layer addSublayer:_captureVideoPreviewLayer];
    
}


/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */
-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position{
    [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice * camera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return camera;
}

// 准备录制视频
- (void)startRecordVideo
{
    
    AVCaptureConnection *connection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    
    if (![self.captureSession isRunning]) {
        //如果捕获会话没有运行
        
        [self.captureSession startRunning];
        
    }
    
    
    //根据连接取得设备输出的数据
    
    if (![self.captureMovieFileOutput isRecording]) {
        //如果输出 没有录制
        
        //如果支持多任务则则开始多任务
        
        if ([[UIDevice currentDevice] isMultitaskingSupported]) {
            
            self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
        }
        
        //预览图层和视频方向保持一致
        
        connection.videoOrientation = [self.captureVideoPreviewLayer connection].videoOrientation;
        
        //开始录制视频使用到了代理 AVCaptureFileOutputRecordingDelegate 同时还有录制视频保存的文件地址的
        
        [self.captureMovieFileOutput startRecordingToOutputFileURL:self.localMovieUrl recordingDelegate:self];
        
    }
}

//停止录制
-(void)stopRecordVideo
{
    if ([self.captureMovieFileOutput isRecording]) {
        
        [self.captureMovieFileOutput stopRecording];
        
    }//把捕获会话也停止的话，预览视图就停了
    
    if ([self.captureSession isRunning]) {
        
        [self.captureSession stopRunning];
    }
    [self setVideoZoomFactor:1];
}

- (void)setVideoZoomFactor:(CGFloat)zoomFactor
{
    AVCaptureDevice * captureDevice = [self.captureDeviceInput device];
    NSError *error = nil;
    [captureDevice lockForConfiguration:&error];
    if (error) return;
    captureDevice.videoZoomFactor = zoomFactor;
    [captureDevice unlockForConfiguration];
}


//开始拍照
-(void)takePhoto:(WXPlayerContro*)vc
{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection=[self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            
            NSData *imageData=[AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image=[UIImage imageWithData:imageData];
            vc.image = image;
            NSLog(@"===========%@",image);
            
//            //是否是自拍的情况下，如果是话镜像进行调换。
//            if (_isFront)
//            {
//                resultImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
//
//            }else{
//                resultImage=image;
//            }
//            [self presentImg:resultImage video:nil];
            
        }
        
    }];
}


#pragma mark 设置视频保存地址
- (NSURL *)localMovieUrl
{
    if (_localMovieUrl == nil) {
        //一个临时的地址   如果使用NSUserDefault 存储的话，重启app还是能够播放
        NSString *outputFilePath=[NSTemporaryDirectory() stringByAppendingString:@"myMovie.mov"];
        
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFilePath];
        
        _localMovieUrl = fileUrl;
    }
    
    return _localMovieUrl;
    
}

/**
 拍摄工具条
 
 @return ShootingToolBar
 */
-(ShootingToolBar*)toolBar
{
    if (!_toolBar) {
        _toolBar = [[ShootingToolBar alloc]initWithFrame:CGRectMake(0, HEIGHT_SCREEN-200-BottomYFit, self.view.frame.size.width, 200)];
        _toolBar.shootingToolBarDelegate = self;
        _toolBar.backgroundColor = [UIColor clearColor];
    }
    return _toolBar;
}

/**
 展示Vc
 
 @return WXPlayerContro
 */
-(WXPlayerContro*)palyerVc
{
    if (!_palyerVc) {
        _palyerVc = [[WXPlayerContro alloc]init];
    }
    return _palyerVc;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - 切换前后相机
//切换摄像头
- (void)btnToggleCameraAction
{
    NSUInteger cameraCount = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = self.captureDeviceInput.device.position;
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        } else {
            return;
        }
        
        if (newVideoInput) {
            [self.captureSession beginConfiguration];
            [self.captureSession removeInput:self.captureDeviceInput];
            if ([self.captureSession canAddInput:newVideoInput]) {
                [self.captureSession addInput:newVideoInput];
                self.captureDeviceInput = newVideoInput;
            } else {
                [self.captureSession addInput:self.captureDeviceInput];
            }
            [self.captureSession commitConfiguration];
        } else if (error) {
            NSLog(@"切换前后摄像头失败");
        }
    }
}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (NSString *)transformSessionPreset
{
    switch (self.sessionPreset) {
        case CaptureSessionPreset325x288:
            return AVCaptureSessionPreset352x288;
            
        case CaptureSessionPreset640x480:
            return AVCaptureSessionPreset640x480;
            
        case CaptureSessionPreset1280x720:
            return AVCaptureSessionPreset1280x720;
            
        case CaptureSessionPreset1920x1080:
            return AVCaptureSessionPreset1920x1080;
            
        case CaptureSessionPreset3840x2160:
            return AVCaptureSessionPreset3840x2160;
    }
}

/**
 截图视频封面
 
 @param url 视频URL
 @return UIImage
 */
- (UIImage *)videoHandlePhoto:(NSURL *)url {
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    imageGenerator.appliesPreferredTrackTransform = YES;    // 截图的时候调整到正确的方向
    NSError *error = nil;
    CMTime time = CMTimeMake(0,30); //缩略图创建时间 CMTime是表示电影时间信息的结构体，第一个参数表示是视频第几秒，第二个参数表示每秒帧数.(如果要获取某一秒的第几帧可以使用CMTimeMake方法)
    CMTime actucalTime; //缩略图实际生成的时间
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actucalTime error:&error];
    if (error) {
        NSLog(@"截取视频图片失败:%@",error.localizedDescription);
    }
    CMTimeShow(actucalTime);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    if (image) {
        NSLog(@"视频截取成功");
    } else {
        NSLog(@"视频截取失败");
    }
    // 移除
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
    return image;
}

- (NSString *)image2DataURL:(UIImage *)image {
    NSData *imageData = nil;
    NSString *mimeType = nil;
    imageData = UIImagePNGRepresentation(image);
    mimeType = @"image/png";
    return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType,
            [imageData base64EncodedStringWithOptions: 0]];
}

-(void)dealloc
{
    NSLog(@"WXShootingVContro销毁");
}

@end
