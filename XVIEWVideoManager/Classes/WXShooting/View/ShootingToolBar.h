//
//  ShootingToolBar.h
//  WeChart
//
//  Created by lk06 on 2018/4/25.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ShootingToolBar;
//类型枚举
enum {
    Photo,
    Video
    
};
typedef NSInteger ActionType;

@protocol shootingToolBarDelegate <NSObject>

/**
 工具条按钮的代理

 @param toolBar ShootingToolBar
 @param index 按钮的值 1、取消 2、确定 3、关闭
 */
-(void)shootingToolBarAction:(ShootingToolBar*)toolBar buttonIndex:(NSInteger)index;


/**
 开始拍照

 @param toolBar 工具条
 @param type 拍摄类型
 @param value 如果是长按，会有进度值
 */
-(void)shooingStart:(ShootingToolBar*)toolBar actionType:(ActionType)type progress:(CGFloat)value;


/**
 结束拍摄

 @param toolBar 工具条
 @param type 拍摄类型
 */
-(void)shootingStop:(ShootingToolBar*)toolBar shootingType:(ActionType)type;

@end

@interface ShootingToolBar : UIView
@property(nonatomic,weak)id<shootingToolBarDelegate> shootingToolBarDelegate;

@end
