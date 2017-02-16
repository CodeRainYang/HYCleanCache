//
//  HYCleanCacheManger.m
//  HYCleanCache(清理缓存)
//
//  Created by DengHengYu on 16/11/11.
//  Copyright © 2016年 杨小雨. All rights reserved.
//

#define FILEMANAGER [NSFileManager defaultManager]
#define WEAK_SELF(type)  __weak typeof(type) weak##type = type

#import "HYCleanCacheManger.h"
#import "MBProgressHUD.h"

@interface HYCleanCacheManger ()
@property (nonatomic ,weak) UIViewController *viewController;
@property (nonatomic, copy)   void(^completion)(BOOL isSuccess);
@end

static HYCleanCacheManger *_manager = nil;

@implementation HYCleanCacheManger

+ (instancetype)shareManger {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
            _manager = [[self alloc] init];
    });
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

//获取单个文件的size
- (long long)fileSizeAtpath:(NSString *)path {
    if (![FILEMANAGER fileExistsAtPath:path]) {
        return 0.0;
    }
    return [[FILEMANAGER attributesOfItemAtPath:path error:nil] fileSize];
}

//获取整个文件夹的size
- (NSString *)folderSizeAtpath:(NSString *)path {

    if (! [FILEMANAGER fileExistsAtPath:path]) {
        return [NSString stringWithFormat:@"0B"];
    }
    
    NSEnumerator *enumerator = [[FILEMANAGER subpathsAtPath:path] objectEnumerator];
    NSString *fileName = [NSString string];
    double folderSize = 0;
    while ((fileName = [enumerator nextObject]) != nil) {
        NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtpath:absolutePath];
    }
  
    if (folderSize < 1024.0 ) {
        return [NSString stringWithFormat:@"%.0fB", folderSize];
    } else if (folderSize < 1024 * 1012){
        return [NSString stringWithFormat:@"%.0fKB", folderSize/1024.0];
    } else {
        return [NSString stringWithFormat:@"%.0fM", folderSize/(1024.0 * 1024)];
    }
}

//获取缓存路径
- (NSString *)getCachePath:(NSString *)fileName {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    if ([fileName isEqualToString:@""] || !fileName ) {
        return cachePath;
    }
    return [cachePath stringByAppendingPathComponent:fileName];
}

//清除指定文件下的所有文件
- (void)cleanCache:(NSString *)path {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.viewController.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = @"正在清除";
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[FILEMANAGER subpathsAtPath:path] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *absolutePath=[path stringByAppendingPathComponent:obj];
            [FILEMANAGER removeItemAtPath:absolutePath error:nil];
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES afterDelay:0.0];
            MBProgressHUD *donehud = [MBProgressHUD showHUDAddedTo:self.viewController.view animated:YES];
            donehud.mode = MBProgressHUDModeCustomView;
            UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            donehud.customView = [[UIImageView alloc] initWithImage:image];
            donehud.square = YES;
            donehud.label.text = @"清理完毕";
            [donehud hideAnimated:YES afterDelay:0.5];
            self.completion(YES);
        });
       
    });
}

//清理缓存
- (void)cleanCacheWithCachepath:(NSString *)cachePath  ShowHUWTo:(UIViewController *)controller animated:(BOOL)animated completion:(void(^)(BOOL isSuccess) )completion{
    self.viewController = controller;
    self.completion = completion;
    NSString *path = [self getCachePath:cachePath];
    NSString  *titleText = [NSString stringWithFormat:@"确定清除缓存吗?"];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:titleText preferredStyle:UIAlertControllerStyleAlert];
    [controller presentViewController:alert animated:YES completion:^{
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        self.completion(NO);
                             }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
    
                                 [self cleanCache:path];

                             }];
    
    [alert addAction:cancel];
    [alert addAction:confirm];
}

@end
