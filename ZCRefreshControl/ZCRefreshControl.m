//
//  ZCPullToRefresh.m
//  ZCPullToRefresh
//
//  Created by xuzhaocheng on 14-10-11.
//  Copyright (c) 2014年 Zhejiang University. All rights reserved.
//

#import "ZCRefreshControl.h"

@interface ZCRefreshControl ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic) UIEdgeInsets oldContentInset;
@property (nonatomic) ZCRefreshControlState controlState;
@property (nonatomic) CGFloat percentage;
@end

static const CGFloat ZCRefreshControlHeight = 50.f;
static const CGFloat circleRadius = 15.f;

@implementation ZCRefreshControl

#pragma mark - Properties

- (void)setPercentage:(CGFloat)percent
{
    if (percent > 1.f)  percent = 1.f;
    _percentage = percent;
}

- (void)setControlState:(ZCRefreshControlState)controlState
{
    _controlState = controlState;
    switch (controlState) {
        case ZCRefreshControlStatePulling:
        case ZCRefreshControlStateNormal:
            self.label.text = @"下拉刷新";
            break;
        case ZCRefreshControlStateRefreshing:
            self.label.text = @"";
            [self setScrollViewContentInsetForRefreshing];
            break;
        case ZCRefreshControlStateTriggerred:
            self.label.text = @"释放刷新";
            break;
        default:
            break;
    }
}

- (UIActivityIndicatorView *)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.hidesWhenStopped = YES;
        [self addSubview:_spinner];
    }
    return _spinner;
}

- (UILabel *)label
{
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.font = [UIFont systemFontOfSize:12.f];
        
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return _label;
}


#pragma mark - Initialization
- (id)init
{
    [NSException raise:NSStringFromClass([self class]) format:@"Use initWithFrame:scrollView or initWithScrollView instead."];
    return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self init];
}

- (id)initWithFrame:(CGRect)frame scrollView: (UIScrollView *)scrollView
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = scrollView;
        [self setup];
    }
    return self;
}

- (id)initWithScrollView: (UIScrollView *)scrollView
{
    CGRect frame = CGRectMake(0, -ZCRefreshControlHeight, scrollView.bounds.size.width, ZCRefreshControlHeight);
    self = [self initWithFrame:frame scrollView:scrollView];
    return self;
}

- (void)setup
{
    self.oldContentInset = self.scrollView.contentInset;
    self.backgroundColor = [UIColor clearColor];
    self.controlState = ZCRefreshControlStateNormal;
    self.percentage = 0.f;
    
    [self.scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    [self.scrollView addObserver:self
                      forKeyPath:@"frame"
                         options:NSKeyValueObservingOptionNew
                         context:nil];

}


#pragma mark - Layout
- (void)layoutSubviews
{
    CGRect currentFrame = self.frame;
    currentFrame.size.width = self.scrollView.bounds.size.width;
    self.frame = currentFrame;
    self.spinner.center = CGPointMake(CGRectGetWidth(self.bounds) / 5, CGRectGetHeight(self.bounds) / 2);
    self.label.frame = self.bounds;
    self.label.center = CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    } else if ([keyPath isEqualToString:@"frame"]) {
        [self layoutSubviews];
    }
}

#pragma mark - ScrollView
- (void)updateScrollViewContentInsets
{
    self.oldContentInset = self.scrollView.contentInset;
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
    switch (self.controlState) {
        case ZCRefreshControlStateNormal:
            if (contentOffset.y < 0)
                self.controlState = ZCRefreshControlStatePulling;
            break;
        case ZCRefreshControlStateRefreshing:
            if (!self.scrollView.isDragging)
                [self adjustScrollViewContentOffsetAndContentInset:contentOffset];
            break;
        case ZCRefreshControlStatePulling:
            [self updateCircleIndicatorWhilePulling:contentOffset];
            if (-contentOffset.y - self.oldContentInset.top > self.bounds.size.height) {
                [self willTriggerRefreshing];
            }
            break;
        case ZCRefreshControlStateTriggerred:
            if (self.controlState != ZCRefreshControlStateRefreshing && !self.scrollView.isDragging) {
                [self triggerRefreshing];
            } else if (-contentOffset.y - self.oldContentInset.top < self.bounds.size.height) {
                self.controlState = ZCRefreshControlStateNormal;
            }
            break;
        default:
            break;
    }
    
}

static const CGFloat Padding = 10.f;
- (void)updateCircleIndicatorWhilePulling:(CGPoint)contentOffset
{
    if (contentOffset.y + self.oldContentInset.top + Padding < 0) {
        self.percentage = (contentOffset.y + self.oldContentInset.top + Padding) / -40.f;
        [self updateUI];
    }
}

- (void)adjustScrollViewContentOffsetAndContentInset:(CGPoint)contentOffset
{
    // 如果offset大于0, 说明没有下拉。
    CGFloat offset = MAX(contentOffset.y * -1, 0.0f);
    offset = MIN(offset, self.bounds.size.height + self.oldContentInset.top);

    UIEdgeInsets contentInset = self.scrollView.contentInset;
    contentInset.top = offset;
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];

}

- (void)setScrollViewContentInsetForRefreshing
{
    [self adjustScrollViewContentOffsetAndContentInset:self.scrollView.contentOffset];
}


#pragma mark - Refreshing

- (void)triggerRefreshing
{
    self.controlState = ZCRefreshControlStateRefreshing;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self.spinner startAnimating];
}

- (void)willTriggerRefreshing
{
     self.controlState = ZCRefreshControlStateTriggerred;
}

#pragma mark - Methods
- (void)beginRefreshing
{
    [self.scrollView setContentOffset:CGPointMake(0, -self.bounds.size.height - self.oldContentInset.top - 1) animated:YES];
    self.controlState = ZCRefreshControlStateTriggerred;
}

- (void)endRefreshing
{
    self.percentage = 0;
    self.controlState = ZCRefreshControlStateNormal;
    [self.spinner stopAnimating];
    [UIView animateWithDuration:.3
                     animations:^{
                         [self.scrollView setContentInset:self.oldContentInset];
                     } completion:^(BOOL finished) {
                         [self updateUI];
                     }];
}



#pragma mark - Drawing
- (void)updateUI
{
    [self setNeedsDisplayInRect:
     CGRectMake(CGRectGetMidX(self.bounds) - circleRadius - 1,
                CGRectGetMidY(self.bounds) - circleRadius - 1,
                circleRadius * 2 + 2,
                circleRadius * 2 + 2)];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (self.controlState == ZCRefreshControlStateRefreshing) {
        
    } else {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path addArcWithCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
                        radius:circleRadius
                    startAngle:2 *M_PI * self.percentage
                      endAngle:0
                     clockwise:NO];
        path.lineCapStyle = kCGLineCapRound;
        path.lineWidth = 2;
        [[UIColor redColor] setStroke];
        [path stroke];
    }
}


@end
