//
//  ViewController.m
//  HYCleanCache(清理缓存)
//
//  Created by 杨小雨 on 16/11/9.
//  Copyright © 2016年 杨小雨. All rights reserved.
//

#import "ViewController.h"
#import "HYCleanCacheManger.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *showCacheSizeCell;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshCacheSize];
}

- (void)refreshCacheSize {
    
    self.showCacheSizeCell.detailTextLabel.text =   [[HYCleanCacheManger shareManger] folderSizeAtpath:[[HYCleanCacheManger shareManger] getCachePath:@""]];
    ;
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self cleanCache];
    }
}

- (void)cleanCache {
    [[HYCleanCacheManger shareManger] cleanCacheWithCachepath:@"" ShowHUWTo:self animated:YES completion:^(BOOL isSuccess) {
        if (isSuccess) {
            self.showCacheSizeCell.detailTextLabel.text = @"0M";
        }
    }];
}

@end
