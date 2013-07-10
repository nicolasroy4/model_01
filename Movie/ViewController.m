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
    
    // Footer View
    // footerView.hidden = YES;
    newsListTableView.tableFooterView = footerView;
    newsListTableView.tableFooterView.backgroundColor = PATTERN(@"CellViewNewsBg");
    [buttonLoadMore addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
    
    // horizontal menu
    self.selectedIndex = 0;
    [self initDataSource];
    [self.horizMenu reloadData];
    UIButton *thisButton = (UIButton*) [self.horizMenu viewWithTag:self.selectedIndex + kButtonBaseTag];
    thisButton.selected = YES;

    [self loadNewsList:16];
    
}

- (void)loadMore
{
    [self loadNewsList:[self.model count] + 16];
}

- (void)loadNewsList:(NSInteger)count
{
    // Arrêt des opérations en cours
    
    [self.operation cancel];
    self.operation = nil;
    
    // Requète + Paramètres
    
    NSLog(@"RELOAD");
    
    NSString *url = [API newsListCount:@(count) category:@(self.selectedIndex)];
    
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
    NSDictionary *newsDetailDict = self.model[indexPath.row];
    cell.newsDetail = newsDetailDict;
    cell.newsImageView.image = [UIImage imageNamed:@"VignetteNewsBg.png"];
    [self downloadImageWithURL:[NSURL URLWithString:newsDetailDict[@"img"]] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            cell.newsImageView.image = image;
        }
    }];
    
    return cell;
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
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
    self.selectedIndex = index;
    [self loadNewsList:16];
}


@end
