//
//  QBTableViewController.h
//  QBBaseProjectFrame
//
//  Created by lizhihui on 2017/3/9.
//  Copyright © 2017年 qianbao. All rights reserved.
//

#import "QBViewController.h"
#import "QBTableViewModel.h"
#import "UIScrollView+EmptyDataSet.h"
@interface QBTableViewController : QBViewController <UITableViewDelegate,UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate> {
    UITableView *_tableView;
}
@property (nonatomic, strong) UITableView *tableView;//!<tableView.
- (void)endRefreshing;
- (void)endLoadMore;
- (BOOL)isRefreshing;
- (BOOL)isLoadingMore;
@end
