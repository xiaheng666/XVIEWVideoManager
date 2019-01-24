//
//  ShootingToolBar.m
//  WeChart
//
//  Created by lk06 on 2018/4/25.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import "ShootingToolBar.h"
#import "ShootingButton.h"
#import "SDAutoLayout.h"
@interface ShootingToolBar()<shootingButtonDelegate>
@property (nonatomic , strong) ShootingButton * shootingButton;
//时间显示
@property (nonatomic , strong) UILabel * timeLabel;
//@property (nonatomic , strong) UIButton * colseButton;
@property (nonatomic , strong) UIButton * leftButton;
@property (nonatomic , strong) UIButton * rightButton;
@property (nonatomic , strong) UIButton * editorButton;
@end
@implementation ShootingToolBar

-(id)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        [self setingSubViews];
        
    }
    
    return self;
}

/**
 设置子控件
 */
-(void)setingSubViews
{
    [self sd_addSubviews:@[self.timeLabel, self.shootingButton,self.leftButton,self.rightButton,self.editorButton]];
    self.shootingButton.sd_layout
    .widthIs(85)
    .centerYEqualToView(self)
    .centerXEqualToView(self)
    .heightIs(85);
    
    self.timeLabel.sd_layout
    .widthIs(100)
    .heightIs(20)
    .centerXEqualToView(self)
    .topEqualToView(self);
//    self.colseButton.sd_layout
//    .widthIs(40)
//    .centerYEqualToView(self)
//    .rightSpaceToView(self.shootingButton, 30)
//    .heightIs(40);
    
    
    self.leftButton.frame  = CGRectMake(self.centerX_sd-35, (self.height*.5)-35, 70, 70);
    self.rightButton.frame = CGRectMake(self.centerX_sd-35, (self.height*.5)-35, 70, 70);
    self.editorButton.frame = CGRectMake(self.centerX_sd-35, (self.height*.5)-35, 70, 70);
}

/**
 小中心录制，拍照按钮

 @return ShootingButton
 */
-(ShootingButton*)shootingButton
{
    if (!_shootingButton) {
        _shootingButton =[ShootingButton getShootingButton];
        _shootingButton.shootingButtonrDelegate=self;
    }
    return _shootingButton;
}

/**
 顶部时间label
 
 @return UILabel
 */
-(UILabel*)timeLabel
{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.hidden = NO;
        _timeLabel.text   = @"长按录制";
        _timeLabel.font   = [UIFont systemFontOfSize:15];
    }
    return _timeLabel;
}
///**
// 关闭按钮
//
// @return UIButton
// */
//-(UIButton*)colseButton
//{
//    if (!_colseButton) {
//        _colseButton = [[UIButton alloc]init];
//        [_colseButton setImage:[UIImage imageNamed:@"icon_cancel"] forState:normal];
//        _colseButton.tag = 3;
//        [_colseButton addTarget:self action:@selector(closeClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _colseButton;
//}

/**
 左侧按钮
 
 @return UIButton
 */
-(UIButton*)leftButton
{
    if (!_leftButton) {
        _leftButton = [[UIButton alloc]init];
        _leftButton.hidden = YES;
        _leftButton.tag = 1;
        _leftButton.backgroundColor = [UIColor greenColor];
        [_leftButton setImage:[UIImage imageNamed:@"btn_return"] forState:normal];
        _leftButton.layer.cornerRadius=35;
        _leftButton.layer.masksToBounds = YES;
        [_leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

/**
 右侧按钮
 
 @return UIButton
 */
-(UIButton*)rightButton
{
    if (!_rightButton) {
        _rightButton = [[UIButton alloc]init];
        _rightButton.hidden = YES;
        _rightButton.layer.cornerRadius=35;
        _rightButton.tag = 4;
        _rightButton.layer.masksToBounds = YES;
        [_rightButton setImage:[UIImage imageNamed:@"btn_sure"] forState:normal];
        [_rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}
/**
 编辑按钮
 
 @return UIButton
 */
-(UIButton*)editorButton
{
    if (!_editorButton) {
        _editorButton = [[UIButton alloc]init];
        _editorButton.hidden = YES;
        [_editorButton setBackgroundColor:[UIColor lightTextColor]];
        _editorButton.layer.cornerRadius=35;
        _editorButton.tag = 3;
        _editorButton.layer.masksToBounds = YES;
        [_editorButton addTarget:self action:@selector(editorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editorButton;
}

#pragma actionClick 事件逻辑
//关闭按钮
-(void)closeClick:(UIButton*)button
{
    if ([self.shootingToolBarDelegate respondsToSelector:@selector(shootingToolBarAction:buttonIndex:)]) {
        [self.shootingToolBarDelegate shootingToolBarAction:self buttonIndex:button.tag];
    }
}
//左侧取消按钮
-(void)leftButtonClick:(UIButton*)button
{
     [self buttonAnimation:NO];
    if ([self.shootingToolBarDelegate respondsToSelector:@selector(shootingToolBarAction:buttonIndex:)]) {
        [self.shootingToolBarDelegate shootingToolBarAction:self buttonIndex:button.tag];
    }
}
//右侧确定按钮
-(void)rightButtonClick:(UIButton*)button
{
    if ([self.shootingToolBarDelegate respondsToSelector:@selector(shootingToolBarAction:buttonIndex:)]) {
        [self.shootingToolBarDelegate shootingToolBarAction:self buttonIndex:button.tag];
    }
}
//编辑按钮
-(void)editorButtonClick:(UIButton*)button
{
    if ([self.shootingToolBarDelegate respondsToSelector:@selector(shootingToolBarAction:buttonIndex:)]) {
        [self.shootingToolBarDelegate shootingToolBarAction:self buttonIndex:button.tag];
    }
}


/**
 左侧和右侧按钮的动画效果

 @param open 打开还是关闭
 */
-(void)buttonAnimation:(BOOL)open
{
//    _colseButton.hidden = open;
    _shootingButton.hidden =open;
    _editorButton.hidden = !open;
    _leftButton.hidden = !open;
    _rightButton.hidden = !open;
    
    if (open) {
        [UIView animateWithDuration:0.4 animations:^{
            _leftButton.transform = CGAffineTransformTranslate(_leftButton.transform, -120, 0);
            _rightButton.transform = CGAffineTransformTranslate(_rightButton.transform, 120, 0);
        }];
        return;
    }
    //隐藏
    _leftButton.transform = CGAffineTransformIdentity;
    _rightButton.transform = CGAffineTransformIdentity;
    
}


#pragma mark 中心按钮的代理方法

/**
 停止录制

 @param button ShootingButton 对象
 @param type 拍照，还是录制
 */
-(void)shootingStop:(ShootingButton *)button shootingType:(shootingType)type
{
    [self buttonAnimation:YES];
     button.hidden = YES;
    self.timeLabel.text = @"长按录制";
    //回调自己的代理
    if ([self.shootingToolBarDelegate respondsToSelector:@selector(shootingStop:shootingType:)]) {
        [self.shootingToolBarDelegate shootingStop:self shootingType:type];
    }
 
}

/**
 开始录制

 @param button 对象
 @param type 拍照，录制类型
 @param value 录制有进度值
 */
-(void)shootingStarting:(ShootingButton *)button shootingType:(shootingType)type progress:(CGFloat)value
{
    //回调自己的代理
    if ([self.shootingToolBarDelegate respondsToSelector:@selector(shooingStart:actionType:progress:)]) {
        if (value == 0){
            self.timeLabel.text = @"长按录制";
        } else {
            self.timeLabel.text = [NSString stringWithFormat:@"%.f秒",value*[[NSUserDefaults standardUserDefaults] doubleForKey:@"recordTime"]];
        }
        [self.shootingToolBarDelegate shooingStart:self actionType:type progress:value];
    }
}

@end
