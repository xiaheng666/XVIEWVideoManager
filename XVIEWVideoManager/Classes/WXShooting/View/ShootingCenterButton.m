//
//  ShootingCenterButton.m
//  WeChart
//
//  Created by lk06 on 2018/4/25.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import "ShootingCenterButton.h"
#import "UIColor+CZAddition.h"
@interface ShootingCenterButton()
@property(nonatomic , strong) UIBezierPath * path;
@property(nonatomic , strong) CAShapeLayer * centerLayer;
@end
@implementation ShootingCenterButton


+(ShootingCenterButton*)getShootingCenterButton:(CGFloat)maxLineW minLineWidth:(CGFloat)minLineW lineColor:(UIColor*)lineColor centerColor:(UIColor*)centerColor
{
        //初始化一个实例对象
        ShootingCenterButton * centerButton = [[ShootingCenterButton alloc]init];
        centerButton.centerLayer = [CAShapeLayer layer];
        centerButton.centerLayer.frame         = centerButton.bounds;
        centerButton.centerLayer.path          = centerButton.path.CGPath; //设置绘制路径
        centerButton.centerLayer.strokeColor   = [UIColor cz_ToUIColorByStr:@"dad9d6"].CGColor;      //设置划线颜色
        centerButton.centerLayer.fillColor     = [UIColor whiteColor].CGColor;   //设置填充颜色
        centerButton.centerLayer.lineWidth     = 13;          //设置线宽
        centerButton.centerLayer.strokeEnd     = 1;        //设置轮廓结束位置
        [centerButton.layer addSublayer:centerButton.centerLayer];
       return centerButton;
}
-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        
        //单击手势
//        UITapGestureRecognizer * singeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleClick)];
//        [self addGestureRecognizer:singeTap];
        
        //长按
        UILongPressGestureRecognizer * longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longClick:)];
        [self addGestureRecognizer:longTap];
        
    }
    return self;
}

//重写布局下子控制器
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.centerLayer.frame    =  self.bounds;
    self.centerLayer.path     =  [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath; //设置绘制路径

}

/**
 长按事件

 @param tap UILongPressGestureRecognizer
 */
-(void)longClick:(UILongPressGestureRecognizer*)tap
{
    //手势开始
    if (tap.state==UIGestureRecognizerStateBegan)
    {
        self.centerLayer.lineWidth = 20;
        if ([self.shootingCenterDelegate respondsToSelector:@selector(shootingStart:obj:)]) {
            //视频开始拍摄
            [self.shootingCenterDelegate shootingStart:LongPressGesture obj:self];
        }
    }
    //判断手势结束
    if (tap.state==UIGestureRecognizerStateEnded) {
        self.centerLayer.lineWidth = 10;
        if ([self.shootingCenterDelegate respondsToSelector:@selector(shootingEnd:obj:)]) {
            //视频结束拍摄
            [self.shootingCenterDelegate shootingEnd:LongPressGesture obj:self];
        }
    }
}
//单击事件
-(void)singleClick
{
    if ([self.shootingCenterDelegate respondsToSelector:@selector(shootingStart:obj:)]) {
        //照片开始拍摄
        [self.shootingCenterDelegate shootingStart:TapGesture obj:self];
    }
    if ([self.shootingCenterDelegate respondsToSelector:@selector(shootingEnd:obj:)]) {
        //照片结束拍摄
        [self.shootingCenterDelegate shootingEnd:TapGesture obj:self];
    }
}

@end
