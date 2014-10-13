//
//  ZCPullToRefresh.h
//  ZCPullToRefresh
//
//  Created by xuzhaocheng on 14-10-11.
//  Copyright (c) 2014年 Zhejiang University. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZCRefreshControlStateNormal,
    ZCRefreshControlStatePulling,
    ZCRefreshControlStateRefreshing,
    ZCRefreshControlStateTriggerred,
} ZCRefreshControlState;

@interface ZCRefreshControl : UIControl

- (id)initWithFrame:(CGRect)frame scrollView: (UIScrollView *)scrollView;
- (id)initWithScrollView: (UIScrollView *)scrollView;

- (void)updateScrollViewContentInsets;
- (void)beginRefreshing;
- (void)endRefreshing;

@end
