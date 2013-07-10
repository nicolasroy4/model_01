//
//  ViewController.m
//  Movie
//
//  Created by Nicolas Roy on 08/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "ViewController.h"
#import "NewsListCell.h"
#import "MKHorizMenu.h"
#import "NewsDetailVC.h"

@interface ViewController ()

@property (nonatomic, strong) MKNetworkOperation *operation;
@property (nonatomic, strong) NSMutableArray *menuItems;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    newsListTableView.delegate = self;
    newsListTableView.dataSource = self;
    
    [self.navigationController.navigationBar setHidden:YES];
    
    // Footer View
    // footerView.hidden = YES;
    newsListTableView.tableFooterView = footerView;
    [buttonLoadMore addTarget:self action:@selector(loadNewsList) forControlEvents:UIControlEventTouchUpInside];
    [self.horizMenu reloadData];
    [self loadNewsList];

}

- (void)loadNewsList
{
    // Arrêt des opérations en cours
    
    [self.operation cancel];
    self.operation = nil;
    
    
    // Requète + Paramètres
    
    NSLog(@"RELOAD");

    NSInteger count = [self.model count] + 16;
    NSString *url = [API newsListCount:@(count) category:@(0)];
    
    self.operation = [NetworkEngine operationWithURL:url params:nil];
    
    // Execution + Handler
    
    __block ViewController *this = self;
    
    [self.operation addCompletionHandler:^(MKNetworkOperation *completedOp) {
        
        NSLog(@"%@", completedOp);
        
      [this loadDataNewsListCompletion:completedOp.responseString];
    
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        
    }];
    
    [[NetworkEngine shared] enqueueOperation:self.operation forceReload:YES];
}


- (void)loadDataNewsListCompletion:(NSString *)jsonString
{
    self.model = [API parseNewsList:jsonString];
    [newsListTableView reloadData];
}

/*----------------------------------------------------------------------------*/
#pragma mark - TableView
/*----------------------------------------------------------------------------*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = [[UIViewController alloc] initWithNibName:@"NewsListCell" bundle:nil];
    NewsListCell *cell = (NewsListCell *)vc.view;
    cell.newsDetail = self.model[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsDetailVC *vc = [[NewsDetailVC alloc] initWithNibName:@"NewsDetailVC" bundle:nil];
    vc.model = self.model[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


/*----------------------------------------------------------------------------*/
#pragma mark - HorizMenu
/*----------------------------------------------------------------------------*/

- (void)initDataSource
{
    self.menuItems = [@[@"item 1", @"item 2", @"item 3", @"item 4", @"item 5", @"item 6"] mutableCopy];
}
/*
- (UIImage *)selectedItemImageForMenu:(MKHorizMenu*)tabMenu
{
    return nil;
}

- (UIColor *)labelColorForMenu:(MKHorizMenu *)tabMenu
{
    return COLOR_DARK_GRAY;
}

- (UIColor *)labelSelectedColorForMenu:(MKHorizMenu *)tabMenu
{
    return COLOR_RED;
}

- (UIColor *)labelHighlightedColorForMenu:(MKHorizMenu *)tabMenu
{
    return COLOR_RED;
}
*/
- (UIFont*) labelFontForMenu:(MKHorizMenu*) tabMenu
{
    return [UIFont boldSystemFontOfSize:14];
}

- (int) itemPaddingForMenu:(MKHorizMenu*) tabMenu
{
    return 14;
}
/*
- (UIColor *)backgroundColorForMenu:(MKHorizMenu *)tabView
{
    return  PATTERN(@"paper_pattern_bg");
}
*/
- (int)numberOfItemsForMenu:(MKHorizMenu *)tabView
{
    return [self.menuItems count];
}

- (NSString *)horizMenu:(MKHorizMenu *)horizMenu titleForItemAtIndex:(NSUInteger)index
{
    return [self.menuItems objectAtIndex:index][@"label"];
}

/* - (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat cX = scrollView.contentOffset.x;
    CGFloat cW = scrollView.contentSize.width;
    CGFloat sW = scrollView.frame.size.width;
    CGFloat offset = 8.f;
    
    BOOL left  = (cX <= offset);
    BOOL right = (cW-(cX+sW) < offset);
    
    [UIView
     animateWithDuration:0.2
     delay:0
     options:UIViewAnimationOptionBeginFromCurrentState
     animations:^{
         fadeLeft.alpha  = (left)  ? 0.0 : 1.0;
         fadeRight.alpha = (right) ? 0.0 : 1.0;
         
     } completion:NULL];
}
*/

- (void)horizMenu:(MKHorizMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index
{
 
}


@end
