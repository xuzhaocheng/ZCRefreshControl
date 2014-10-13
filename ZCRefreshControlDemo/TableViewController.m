//
//  TableViewController.m
//  ZCPullToRefresh
//
//  Created by xuzhaocheng on 14-10-11.
//  Copyright (c) 2014年 Zhejiang University. All rights reserved.
//

#import "TableViewController.h"
#import "ZCRefreshControl.h"

@interface TableViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) ZCRefreshControl *pullRefresh;
@end

@implementation TableViewController

- (ZCRefreshControl *)pullRefresh
{
    if (!_pullRefresh) {
        _pullRefresh = [[ZCRefreshControl alloc] initWithScrollView:self.tableView];
        [_pullRefresh addTarget:self
                         action:@selector(refresh)
               forControlEvents:UIControlEventValueChanged];
    }
    return _pullRefresh;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView addSubview:self.pullRefresh];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Refresh"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(triggerRefresh)];
}

- (void)refresh
{
    NSLog(@"Refresh");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pullRefresh endRefreshing];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pullRefresh updateScrollViewContentInsets];
    
//    [self.pullRefresh beginRefreshing];
}

- (void)triggerRefresh
{
    [self.pullRefresh beginRefreshing];
}


#pragma mark - TableViewDataSource

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//     Return the number of rows in the section.
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
