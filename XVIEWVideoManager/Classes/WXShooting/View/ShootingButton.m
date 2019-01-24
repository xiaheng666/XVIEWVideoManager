//
//  ShootingToolView.m
//  WeChart
//
//  Created by lk06 on 2018/4/25.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import "ShootingButton.h"
#import "ShootingCenterButton.h"
#import "SDAutoLayout.h"
#import "UIColor+CZAddition.h"
@interface ShootingButton ()<shootingCenterDelegate>
@property (nonatomic , strong)  ShootingCenterButton * centerButton;
@property (nonatomic , strong) CAShapeLayer * progressLayer;
@property (nonatomic , strong) CADisplayLink * displayLink;
@property (nonatomic , assign) CGFloat progressValue;
@end
@implementation ShootingButton
+(ShootingButton*)getShootingButton
{
    
    ShootingButton * shootingButton = [[ShootingButton alloc]init];
    
    #pragma makr-----进度圈内部按钮----
    ShootingCenterButton * centerButton = [ShootingCenterButton getShootingCenterButton:20 minLineWidth:10 lineColor:nil centerColor:nil];
    shootingButton.centerButton = centerButton;
    centerButton.shootingCenterDelegate=shootingButton;
    [shootingButton addSubview:centerButton];
    centerButton.sd_layout.spaceToSuperView(UIEdgeInsetsMake(9, 9, 9, 9));
    
    
    #pragma makr-----进度圈----
    shootingButton.progressLayer    = [CAShapeLayer layer];
    shootingButton.progressLayer.strokeColor   = [UIColor cz_ToUIColorByStr:@"1aad19"].CGColor;      //设置划线颜色
    shootingButton.progressLayer.fillColor     = [UIColor clearColor].CGColor;   //设置填充颜色
    shootingButton.progressLayer.lineWidth     = 3;          //设置线宽
    shootingButton.progressLayer.strokeStart   = 0;
    shootingButton.progressLayer.strokeEnd     = 0;        //设置轮廓结束位置
    //旋转到垂直方向
    CATransform3D turnTrans = CATransform3DMakeRotation(-M_PI / 2, 0, 0, 1);
    shootingButton.progressLayer.transform= turnTrans;
    [shootingButton.layer addSublayer:shootingButton.progressLayer];
    return shootingButton;
    
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.progressLayer.frame         = self.bounds;
    self.progressLayer.path          = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath; //设置绘制路径

}


#pragma mark ------------shootingCenterDelegate-----------------
/**
 开始录制或者拍照
 
 @param action 判断拍照还是录制类型
 */
-(void)shootingStart:(TapType)action obj:(ShootingCenterButton *)button
{
    //长按的手势（开启定时器）
    if (action==LongPressGesture) {
         self.progressLayer.strokeColor = [UIColor greenColor].CGColor;
         self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(changeProgerss)];
         [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }

    //回调自己的代理(开始)
    if ([self.shootingButtonrDelegate respondsToSelector:@selector(shootingStarting:shootingType:progress:)]) {
        [self.shootingButtonrDelegate shootingStarting:self shootingType:action progress:self.progressValue];
    }
}
/**
 录制或者拍照结束的回调
 
 @param action 判断拍照还是录制类型
 */
-(void)shootingEnd:(TapType)action obj:(ShootingCenterButton *)button
{
    if (action==LongPressGesture) {
        [self stopProress];
    }
    
    //回调自己的代理(结束)
    if ([self.shootingButtonrDelegate respondsToSelector:@selector(shootingStop:shootingType:)]) {
        [self.shootingButtonrDelegate shootingStop:self shootingType:action];
    }
    
}

#pragma mark action --------------事件处理逻辑----------------

/**
 修改进度要的状态（定时器实时调用的方法）
 */
-(void)changeProgerss
{
    double speed = (1.0/[[NSUserDefaults standardUserDefaults] doubleForKey:@"recordTime"])/60.0;//拍摄的时间
    self.progressValue = self.progressValue + speed;
    self.progressLayer.strokeEnd = self.progressValue;
    if (self.progressValue >= 1.05) {
        [self stopProress];
    }
    
    //回调自己的代理(开始)
    if ([self.shootingButtonrDelegate respondsToSelector:@selector(shootingStarting:shootingType:progress:)]) {
        [self.shootingButtonrDelegate shootingStarting:self shootingType:LongPressGesture progress:self.progressValue];
    }
}

/**
 结束视频的拍摄
 */
-(void)stopProress
{
    self.progressValue = 0;
    self.progressLayer.strokeEnd =   self.progressValue;
    self.progressLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.displayLink invalidate];
}

@end
