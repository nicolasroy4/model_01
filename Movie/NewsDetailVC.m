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
    
    self.view.backgroundColor = PATTERN(@"LightGreyBg");

    [self loadNewsDetail:nil];
    
    // back button
    UIImage *bgb = STRETCH(@"NavBarButtonBgBack", 14, 0);
    [backButton setBackgroundImage:bgb forState:UIControlStateNormal];
    UIImage *bgbh = STRETCH(@"NavBarButtonBgBack_highlighted", 14, 0);
    [backButton setBackgroundImage:bgbh forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];

    // prev/next button
    UIImage *bg = STRETCH(@"NavBarButtonBg", 8, 0);
    [buttonPrev setBackgroundImage:bg forState:UIControlStateNormal];
    [buttonNext setBackgroundImage:bg forState:UIControlStateNormal];
    UIImage *bgh = STRETCH(@"NavBarButtonBg_highlighted", 8, 0);
    [buttonPrev setBackgroundImage:bgh forState:UIControlStateHighlighted];
    [buttonNext setBackgroundImage:bgh forState:UIControlStateHighlighted];
    [buttonPrev addTarget:self action:@selector(loadPrevNews) forControlEvents:UIControlEventTouchUpInside];
    [buttonNext addTarget:self action:@selector(loadNextNews) forControlEvents:UIControlEventTouchUpInside];

    
    // webview
    webView.delegate = (id<UIWebViewDelegate>)self;
}

- (void)loadPrevNews
{
    [self loadNewsDetail:self.newsDetail[@"prev"]];
}

- (void)loadNextNews
{
    [self loadNewsDetail:self.newsDetail[@"next"]];
}

- (void)loadNewsDetail:(NSString*)newsUrl
{
    // Arrêt des opérations en cours
    
    [self.operation cancel];
    self.operation = nil;
    
    
    // Requète + Paramètres
    
    NSLog(@"RELOAD");
    
    NSString *newsID = self.model[@"id"];
    
    NSString *url;
    if (!newsUrl) {
        url = [API newsDetail:@(newsID.integerValue)];
    } else {
        url = newsUrl;
    }
    
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
    // get localized path for file from app bundle
	NSString *path;
	NSBundle *thisBundle = [NSBundle mainBundle];
	path = [thisBundle pathForResource:@"news_phone" ofType:@"html"];
    
	// make a file: URL out of the path
	NSError *error;
    NSString *initialHTMLString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    NSString *titleString = self.newsDetail[@"title"];
    NSString *dateString = self.newsDetail[@"date"];
    NSString *chapoString = self.newsDetail[@"chapo"];
    NSString *htmlString = self.newsDetail[@"description"];
    NSString *authorString = self.newsDetail[@"author"];
    NSString *imgString = self.newsDetail[@"img"];
    
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%title%%%" withString:titleString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%date%%%" withString:dateString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%chapo%%%" withString:chapoString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%html%%%" withString:htmlString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%author%%%" withString:authorString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%img%%%" withString:imgString];
    
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%diapo%%%" withString:@""];

    while ([self stringBetweenString:@"[idVideo]" andString:@"[/idVideo]" in:initialHTMLString]) {
        NSString *videoID = [self stringBetweenString:@"[idVideo]" andString:@"[/idVideo]" in:initialHTMLString];
        NSString *videoIdLoc = [NSString stringWithFormat:@"[idVideo]%@[/idVideo]",videoID];
        NSDictionary *videoUrls = self.newsDetail[@"videoBrightcove"];
        initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:videoIdLoc withString:videoUrls[videoID]];
    }
    
    [webView loadHTMLString:initialHTMLString baseURL:nil];
}

-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end in:(NSString*)myString{
    NSScanner* scanner = [NSScanner scannerWithString:myString];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if ([scanner scanString:start intoString:NULL]) {
        NSString* result = nil;
        if ([scanner scanUpToString:end intoString:&result]) {
            return result;
        }
    }
    return nil;
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
    loadingView.alpha = 0.0f;
    
    [spinner startAnimating];
    
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:(UIViewAnimationCurveEaseInOut |
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         loadingView.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {}];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    [self webViewDidFinishLoad:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    [UIView animateWithDuration:0.1f
                          delay:0.0f
                        options:(UIViewAnimationCurveEaseInOut |
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         
                         loadingView.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         [spinner stopAnimating];
                     }];
}


@end
