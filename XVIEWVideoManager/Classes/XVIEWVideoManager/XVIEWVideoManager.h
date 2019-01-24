//
//  XVIEWVideoManager.h
//  XVIEWVideoManager
//
//  Created by yyj on 2019/1/7.
//  Copyright © 2019 zd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XVIEWVideoManager : NSObject

/**
 *  单例
 */
+ (instancetype)sharedVideoManager;

/**
 *  拍摄小视屏
 @param param     data:{time:录制时间(默认10秒)}
                  callback:回调方法
                  currentVC:当前vc
 */
- (void)video:(NSDictionary *)param;

@end
