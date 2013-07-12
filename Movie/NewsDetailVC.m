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
@property (nonatomic) NSInteger policeSize;
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
    
    // size up / size down  buttons
    self.policeSize = 15;
    UITapGestureRecognizer *tapUp = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sizeUp)];
    [buttonSizeUp addGestureRecognizer:tapUp];
    
    UITapGestureRecognizer *tapDown = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sizeDown)];
    [buttonSizeDown addGestureRecognizer:tapDown];
    
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
    NSString *dateString = [[NSString stringWithFormat:@"%@ %@", [DateHelper dateFormat:self.newsDetail[@"date"]], self.newsDetail[@"hour"]] capitalizedString];
    NSString *chapoString = self.newsDetail[@"chapo"];
    NSString *htmlString = self.newsDetail[@"description"];
    NSString *authorString = self.newsDetail[@"author"];
    NSString *imgString = self.newsDetail[@"img"];
    NSString *sizeString = [NSString stringWithFormat:@"%d", self.policeSize] ;
    
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%title%%%" withString:titleString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%date%%%" withString:dateString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%chapo%%%" withString:chapoString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%html%%%" withString:htmlString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%author%%%" withString:authorString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%img%%%" withString:imgString];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%size%%%" withString:sizeString];
    
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%diapo%%%" withString:@""];
    initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:@"%%%more-news%%%" withString:@""];
    
    while ([self stringBetweenString:@"[idVideo]" andString:@"[/idVideo]" in:initialHTMLString]) {
        NSString *videoID = [self stringBetweenString:@"[idVideo]" andString:@"[/idVideo]" in:initialHTMLString];
        NSString *videoIdLoc = [NSString stringWithFormat:@"[idVideo]%@[/idVideo]",videoID];
        NSDictionary *videoUrls = self.newsDetail[@"videoBrightcove"];
        initialHTMLString = [initialHTMLString stringByReplacingOccurrencesOfString:videoIdLoc withString:videoUrls[videoID]];
    }
    
    while ([self stringBetweenString:@"[videoExterne]" andString:@"[/videoExterne]" in:initialHTMLString]) {
        NSString *videotype = [self stringBetweenString:@"[videoExterne]" andString:@"_" in:initialHTMLString];
        NSString *videoID = [self stringBetweenString:@"_" andString:@"[/videoExterne]" in:initialHTMLString];
        NSString *videoIdLoc = [NSString stringWithFormat:@"[videoExterne]%@_%@[/videoExterne]",videotype, videoID];
        NSDictionary *videoTypesUrls = self.newsDetail[@"videosExternes"];
        NSDictionary *videoUrls = videoTypesUrls[videotype];

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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked){
        NSString *requestString = [request.URL absoluteString];
        if ([self string:requestString containsString:@"http://api.programme-tv.net/1326279455-10/getNews/?id"]) {
            [self loadNewsDetail:[request.URL absoluteString]];
        } else {
            [[UIApplication sharedApplication] openURL:[request URL]];
        }
        return NO;
    }
    
    return YES;
}

- (BOOL)string:(NSString*)bigString containsString:(NSString*)smallString
{
    NSRange isRange = [bigString rangeOfString:smallString];
    if(isRange.location != NSNotFound) {
        return YES;
    }
    return NO;
}

-(void)sizeUp {
    if (self.policeSize < 24) {
        NSString *jsPrintHeadOfTable=[[NSString alloc]initWithFormat:@"changeFontSize('content','+2')"];
        [webView stringByEvaluatingJavaScriptFromString:jsPrintHeadOfTable];
        self.policeSize += 2;
    }
}

-(void)sizeDown {
    if (self.policeSize > 10) {
        NSString *jsPrintHeadOfTable=[[NSString alloc]initWithFormat:@"changeFontSize('content','-2')"];
        [webView stringByEvaluatingJavaScriptFromString:jsPrintHeadOfTable];
        self.policeSize -= 2;
    }
}

@end
