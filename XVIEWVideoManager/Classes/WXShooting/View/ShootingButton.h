//
//  ShootingToolView.h
//  WeChart
//
//  Created by lk06 on 2018/4/25.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ShootingButton;
//类型枚举
enum {
    PhotoType,
    VideoType
    
};
typedef NSInteger shootingType;

@protocol shootingButtonDelegate <NSObject>

/**
 录制或者拍照完毕调用方法

 @param button  ShootingButton
 @param type  录制的类型
 */
-(void)shootingStop:(ShootingButton*)button shootingType:(shootingType)type;

/**
 录制或者拍照开始调用方法
 
 @param button  ShootingButton
 @param type  录制的类型
 @param value 进度值
 */
-(void)shootingStarting:(ShootingButton*)button shootingType:(shootingType)type progress:(CGFloat)value;

@end
@interface ShootingButton : UIView
@property(nonatomic,weak)id<shootingButtonDelegate> shootingButtonrDelegate;
+(ShootingButton*)getShootingButton;
@end
