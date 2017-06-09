//
//  QBTableViewController.m
//  QBBaseProjectFrame
//
//  Created by lizhihui on 2017/3/9.
//  Copyright © 2017年 qianbao. All rights reserved.
//

#import "QBTableViewController.h"
#import <QBRefresh/QBRefresh_T3.h>
#import <MJRefresh/MJRefresh.h>

@interface QBTableViewController ()
@property (nullable, nonatomic, strong, readwrite) QBTableViewModel *viewModel;
@end

@implementation QBTableViewController
@dynamic viewModel;

- (instancetype)initWithViewModel:(id<QBViewModelProtocol>)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self) {
        if (self.viewModel.isCanRefresh) {
            @weakify(self);
            [[self rac_signalForSelector:@selector(viewDidLoad)] subscribeNext:^(id  _Nullable x) {
                @strongify(self);
                [self.viewModel.requestDataCommand execute:@1];
            }];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    __weak typeof(self)weakSelf = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(weakSelf.view);
        make.top.mas_equalTo(64);
    }];
    
    [RACObserve(self.viewModel, isCanRefresh) subscribeNext:^(NSNumber *x) {
        if (x.boolValue) {
            [weakSelf addRefreshHeader];
        }else {
            weakSelf.tableView.qb_header = nil;
        }
    }];
    [RACObserve(self.viewModel, isCanLoadMore)subscribeNext:^(NSNumber *x) {
        if (x.boolValue) {
            [weakSelf addRefreshFooter];
        }else {
            weakSelf.tableView.mj_footer = nil;
        }
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

-(void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)bindViewModel {
    [super bindViewModel];
    
    @weakify(self);
    [[[RACObserve(self.viewModel, dataSource)
       distinctUntilChanged]
      deliverOnMainThread]
     subscribeNext:^(id  _Nullable x) {
         @strongify(self);
         [self.tableView reloadData];
     }];
}

- (BOOL)isRefreshing {
    return [self.tableView.qb_header isRefreshing];
}

- (BOOL)isLoadingMore {
    return [self.tableView.mj_footer isRefreshing];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = [UIView new];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _tableView;
}

#pragma mark - private methods

- (void)addRefreshHeader {
    if (!_tableView.qb_header) {
        _tableView.qb_header = [QBRefreshHeader_T3 headerWithRefreshingBlock:^{
            [self.viewModel loadData];
            [self.viewModel.requestDataCommand execute:@1];
        }];
    }
}

- (void)addRefreshFooter {
    if (!_tableView.mj_footer) {
        MJRefreshAutoStateFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [self.viewModel.requestLoadMoreDataCommand execute:@1];
        }];
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        [footer setTitle:@"加载中" forState:MJRefreshStateRefreshing];
        [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
#warning refresh footer css
        footer.stateLabel.font = [UIFont systemFontOfSize:15];
        footer.stateLabel.textColor = [UIColor grayColor];
        self.tableView.mj_footer = footer;
    }
}

#pragma mark - tableview datasource/delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.viewModel.didSelectCommand execute:indexPath];
}


#pragma mark - DZNEmptyDataSetDelegate methods

//- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
//    return NO;
//}

#pragma mark - DZNEmptyDataSetSource methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"暂无数据";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f], NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)endRefreshing {
    [self.tableView.qb_header endRefreshing];
}
- (void)endLoadMore {
    [self.tableView.mj_footer endRefreshing];
}

@end
