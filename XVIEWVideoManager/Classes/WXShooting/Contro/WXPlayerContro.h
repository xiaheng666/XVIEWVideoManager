//
//  WXPlayerContro.h
//  WeChart
//
//  Created by lk06 on 2018/4/26.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

@interface WXPlayerContro : UIViewController
@property (nonatomic , strong)NSURL * url;
@property (nonatomic , strong)UIImage * image;
@property (nonatomic , strong) AVPlayerItem * playerItem;
@property (nonatomic , strong) AVPlayer * player;
@property (nonatomic , strong) UIImageView * imageView;
@property (nonatomic , strong) AVPlayerLayer *playerLayer;
-(void)removeSubViews;
@end
