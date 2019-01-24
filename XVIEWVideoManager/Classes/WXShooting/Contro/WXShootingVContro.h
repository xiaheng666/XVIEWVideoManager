//
//  WXShootingVContro.h
//  WeChart
//
//  Created by lk06 on 2018/4/26.
//  Copyright © 2018年 lk06. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ RecordBlock)(NSDictionary *dict);

@interface WXShootingVContro : UIViewController

@property (copy, nonatomic) RecordBlock recordBlock;

@end
