//
//  ShootingCenterButton.h
//  WeChart
//
//  Created by lk06 on 2018/4/25.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShootingCenterButton;

//类型枚举
enum {
    TapGesture,
    LongPressGesture
    
};
typedef NSInteger TapType;
@protocol shootingCenterDelegate <NSObject>

/**
 开始录制或者拍照
 
 @param action 判断拍照还是录制类型
 */
-(void)shootingStart:(TapType)action obj:(ShootingCenterButton*)button;

/**
 录制或者拍照结束的回调
 
 @param action 判断拍照还是录制类型
 */
-(void)shootingEnd:(TapType)action obj:(ShootingCenterButton*)button;

@end

@interface ShootingCenterButton : UIView

 @property(nonatomic,weak)id<shootingCenterDelegate> shootingCenterDelegate;
+(ShootingCenterButton*)getShootingCenterButton:(CGFloat)maxLineW minLineWidth:(CGFloat)minLineW lineColor:(UIColor*)lineColor centerColor:(UIColor*)centerColor;
@end
