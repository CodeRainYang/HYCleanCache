//
//  HYCleanCacheManger.h
//  HYCleanCache(清理缓存)
//
//  Created by DengHengYu on 16/11/11.
//  Copyright © 2016年 杨小雨. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface HYCleanCacheManger : NSObject
+ (instancetype)shareManger;

/*
 * 获取缓存路径
 *
 * @prama fileName   Cache的文件夹名称
 */
- (NSString *)getCachePath:(NSString *)fileName;

/*
 * 获取缓存文件大小
 *
 * @prama path   缓存路径
 */
- (NSString *)folderSizeAtpath:(NSString *)path;

/*
 * 清理缓存
 *
 * @prama path        缓存路径
 * @prama controller  当前的视图控制器
 * @prama animated    HUD是否有动画效果
 * @prama isSuccess  清理结果回调 YES 成功 / NO 失败 
 */
- (void)cleanCacheWithCachepath:(NSString *)cachePath ShowHUWTo:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(BOOL isSuccess) )completion;


@end
