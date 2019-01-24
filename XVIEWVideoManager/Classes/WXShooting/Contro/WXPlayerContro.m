//
//  WXPlayerContro.m
//  WeChart
//
//  Created by lk06 on 2018/4/26.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import "WXPlayerContro.h"
//#import <AVFoundation/AVFoundation.h>
@interface WXPlayerContro ()

@end

@implementation WXPlayerContro

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

}

//视频结束后重新播放
- (void)runLoopTheMovie:(NSNotification *)n{
    AVPlayerItem * p = [n object];
    //关键代码
    [p seekToTime:kCMTimeZero];
    [self.player play];
}
-(void)setUrl:(NSURL *)url
{
    // 1、得到视频的URL
    NSURL *movieURL = url;
    // 2、根据URL创建AVPlayerItem
    self.playerItem   = [AVPlayerItem playerItemWithURL:movieURL];
    // 3、把AVPlayerItem 提供给 AVPlayer
    self.player     = [AVPlayer playerWithPlayerItem:self.playerItem];
    // 4、AVPlayerLayer 显示视频。
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    _playerLayer.frame       = self.view.bounds;
    //设置边界显示方式
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.view.layer insertSublayer:_playerLayer atIndex:0];
    
    [self.player play];

}
-(void)setImage:(UIImage *)image
{
    
    _imageView = [[UIImageView alloc]init];
    _imageView.frame = self.view.bounds;
    _imageView.image = image;
    [self.view addSubview:_imageView];
    
}
-(void)removeSubViews
{
    [self.player pause];
    [_imageView removeFromSuperview];
    [self.playerLayer removeFromSuperlayer];
    [self.view removeFromSuperview];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    NSLog(@"WXPlayerContro销毁了");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
