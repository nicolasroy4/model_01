//
//  NewsDetailVC.m
//  Movie
//
//  Created by Nicolas ROY on 10/07/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "NewsDetailVC.h"

@interface NewsDetailVC ()
@property (nonatomic, strong) MKNetworkOperation *operation;

@end

@implementation NewsDetailVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self loadNewsDetail];
    
    // back button
    
    UIImage *bg = STRETCH(@"NavBarButtonBgBack", 14, 0);
    [backButton setBackgroundImage:bg forState:UIControlStateNormal];
    UIImage *bgh = STRETCH(@"NavBarButtonBgBack_highlighted", 14, 0);
    [backButton setBackgroundImage:bgh forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

    
    // webview
    webView.delegate = (id<UIWebViewDelegate>)self;
    
    // building scrollView
    [scrollView addSubview:contentView];
    scrollView.contentSize = contentView.bounds.size;
}


- (void)loadNewsDetail
{
    // Arrêt des opérations en cours
    
    [self.operation cancel];
    self.operation = nil;
    
    
    // Requète + Paramètres
    
    NSLog(@"RELOAD");
    
    NSString *newsID = self.model[@"id"];
    NSString *url = [API newsDetail:@(newsID.integerValue)];
    
    self.operation = [NetworkEngine operationWithURL:url params:nil];
    
    // Execution + Handler
    
    __block NewsDetailVC *this = self;
    
    [self.operation addCompletionHandler:^(MKNetworkOperation *completedOp) {
        
        NSLog(@"%@", completedOp);
        
        [this loadDataNewsDetailCompletion:completedOp.responseString];
        
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        
    }];
    
    [[NetworkEngine shared] enqueueOperation:self.operation forceReload:YES];
}


- (void)loadDataNewsDetailCompletion:(NSString *)jsonString
{
    self.newsDetail = [API parseNewsDetail:jsonString];
    [self loadWebView];
    [self customizeWebView];
}
- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

//------------------------------------------------------------------------------
#pragma mark - WebView
//------------------------------------------------------------------------------

- (void)loadWebView
{    
    labelTitle.text = self.newsDetail[@"title"];
    labelDate.text = self.newsDetail[@"date"];
    
    [webView loadHTMLString:self.newsDetail[@"description"] baseURL:nil];

    NSString *imageURL = self.newsDetail[@"img"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    newsImageView.image = [UIImage imageWithData:imageData];
    newsImageView.contentMode = UIViewContentModeScaleAspectFit;

}

- (void)customizeWebView
{
    webView.opaque = NO;
	webView.backgroundColor = [UIColor clearColor];
    
    // remove shadow
    for (UIView *wview in [[[webView subviews] objectAtIndex:0] subviews])
        if([wview isKindOfClass:[UIImageView class]])
            wview.hidden = YES;
}


//------------------------------------------------------------------------------
#pragma mark - WebView Delegate (loading indicator)
//------------------------------------------------------------------------------

- (void)webViewDidStartLoad:(UIWebView *)wv
{
   /* spinner.alpha = 0.0f;
    
    [spinner startAnimating];
    
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:(UIViewAnimationCurveEaseInOut |
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         spinner.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {}];
    */
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [self webViewDidFinishLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
 /*   [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:(UIViewAnimationCurveEaseInOut |
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         spinner.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         [spinner stopAnimating];
                     }];
  */
}


@end
