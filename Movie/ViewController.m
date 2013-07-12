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
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, readonly) NSArray* topNewsArray;
@property (nonatomic) BOOL isLoadable;
@property (nonatomic) BOOL newSection;

@end

@implementation ViewController
#define kButtonBaseTag 10000

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    self.view.backgroundColor = PATTERN(@"LightGreyBg");
    
    newsListTableView.delegate = self;
    newsListTableView.dataSource = self;
    
    [self.navigationController.navigationBar setHidden:YES];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    [newsListTableView addSubview:self.refreshControl];
    
    // Footer View
    footerView.backgroundColor = PATTERN(@"CellViewNewsBg");
    [buttonLoadMore addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    [spinner setHidden:YES];
    
    // horizontal menu
    self.selectedIndex = 0;
    [self initDataSource];
    [self.horizMenu reloadData];
    UIButton *thisButton = (UIButton*) [self.horizMenu viewWithTag:self.selectedIndex + kButtonBaseTag];
    thisButton.selected = YES;
    
    loadingView.alpha = 0.0f;
    self.isLoadable = YES;
    self.newSection = YES;
    [self initialLoad];
}

- (void)initialLoad
{
    loadingView.alpha = 1.0f;
    [spinner startAnimating];
    [self loadNewsList:16];
}

- (void)loadMore
{
    [self loadNewsList:[self.model count] + 16];
}

- (void)refreshData
{
    [self loadNewsList:16];
}

- (void)loadNewsList:(NSInteger)count
{
 
    if (self.isLoadable == NO) return;
        
    // Arrêt des opérations en cours
    
    [self.operation cancel];
    self.operation = nil;
    
    [spinnerfooter startAnimating];
    [spinnerfooter setHidden:NO];
    
    // Requète + Paramètres
    
    NSString *url = [API newsListCount:@(count) category:@(self.selectedIndex)];
    
    self.operation = [NetworkEngine operationWithURL:url params:nil];
    
    // Execution + Handler
    
    __block ViewController *this = self;
    
    [self.operation addCompletionHandler:^(MKNetworkOperation *completedOp) {
        
        NSLog(@"%@", completedOp);
        
        [this loadDataNewsListCompletion:completedOp.responseString];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        this.isLoadable = YES;
    }];
    
    [[NetworkEngine shared] enqueueOperation:self.operation forceReload:YES];
}

-(NSArray *)topNewsArray
{
    return @[@1,@2];
}

- (void)loadDataNewsListCompletion:(NSString *)jsonString
{
    loadingView.alpha = 0.0f;
    [spinnerfooter stopAnimating];
    [spinner stopAnimating];
    [spinner setHidden:YES];
    [self.refreshControl endRefreshing];
    
    NSArray *apiArray = [API parseNewsList:jsonString];
    
    NSMutableArray *myArray = [[NSMutableArray alloc] initWithCapacity:[apiArray count]];
    
    int j = 0;
    int i = 1;
    
    while (j < 2) {
        for (NSDictionary *myNews in apiArray) {
            if (myNews[@"topNews"] && [myNews[@"topNews"]intValue] == i) {
                [myArray addObject:myNews];
                i++;
            }
        }
        
        if (i==3) break;
        j++;
    }
    
    for (NSDictionary *myNews in apiArray) {
        if (!myNews[@"topNews"] || !([self.topNewsArray containsObject:myNews[@"topNews"]])) {
            [myArray addObject:myNews];
        }
    }
    
    if ([self.model count] == [myArray count] && self.newSection == NO)
    {
        self.isLoadable = NO;
        
    } else {
        self.model = myArray;
        [newsListTableView reloadData];
        self.isLoadable = YES;
    }
    
    self.newSection = NO;
}

/*----------------------------------------------------------------------------*/
#pragma mark - TableView
/*----------------------------------------------------------------------------*/

- (void)setIsLoadable:(BOOL)isLoadable
{
    
    if (isLoadable) {
        newsListTableView.tableFooterView = footerView;
    } else {
        newsListTableView.tableFooterView = nil;
    }
    
    _isLoadable = isLoadable;
}

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
    NSDictionary *newsDetailDict = self.model[indexPath.row];
    if(newsDetailDict[@"topNews"] && ([self.topNewsArray containsObject:newsDetailDict[@"topNews"]])) {
        return 125.f;
    } else {
        return 86.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *newsDetailDict = self.model[indexPath.row];
    BOOL isTop = (newsDetailDict[@"topNews"] && ([self.topNewsArray containsObject:newsDetailDict[@"topNews"]]));
    
    UIViewController *vc;
    if (isTop) vc = [[UIViewController alloc] initWithNibName:@"NewsListBigCell" bundle:nil];
    else vc = [[UIViewController alloc] initWithNibName:@"NewsListCell" bundle:nil];

    NewsListCell *cell = (NewsListCell *)vc.view;
    cell.newsDetail = newsDetailDict;
    
        
    if (indexPath.row == [self.model count]-1){
        [self loadMore];
    }
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
    self.menuItems = [@[@"Tous", @"Cinéma", @"TV", @"Séries TV", @"Télé-Réalité", @"People", @"Buzz", @"Sport", @"Jeux vidéo"] mutableCopy];
}

- (UIImage *)selectedItemImageForMenu:(MKHorizMenu*)tabMenu
{
    return STRETCH(@"category_item_selected_bg",6,0);
}

- (UIColor *)labelColorForMenu:(MKHorizMenu *)tabMenu
{
    return [UIColor whiteColor];
}

- (UIColor *)labelSelectedColorForMenu:(MKHorizMenu *)tabMenu
{
    return [UIColor whiteColor];
}

- (UIColor *)labelHighlightedColorForMenu:(MKHorizMenu *)tabMenu
{
    return [UIColor whiteColor];
}

- (UIFont*) labelFontForMenu:(MKHorizMenu*) tabMenu
{
    return [UIFont boldSystemFontOfSize:12];
}

- (int) itemPaddingForMenu:(MKHorizMenu*) tabMenu
{
    return 20;
}

- (UIColor *)backgroundColorForMenu:(MKHorizMenu *)tabView
{
    return  PATTERN(@"category_slidebar_bg");
}

- (int)numberOfItemsForMenu:(MKHorizMenu *)tabView
{
    return [self.menuItems count];
}

- (NSString *)horizMenu:(MKHorizMenu *)horizMenu titleForItemAtIndex:(NSUInteger)index
{
    return [self.menuItems objectAtIndex:index];
}

- (void)horizMenu:(MKHorizMenu *)horizMenu itemSelectedAtIndex:(NSUInteger)index
{
    self.selectedIndex = index;
    self.newSection = YES;
    self.isLoadable = YES;
    [self initialLoad];
    [newsListTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
}

@end
