//
//  NewsDetailVC.h
//  Movie
//
//  Created by Nicolas ROY on 10/07/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsDetailVC : UIViewController
{
    
    IBOutlet UIWebView *webView;
    IBOutlet UIButton *backButton;
    IBOutlet UIView *loadingView;
    IBOutlet UIActivityIndicatorView *spinner;
    IBOutlet UIButton *buttonPrev;
    IBOutlet UIButton *buttonNext;
}

@property (nonatomic, strong) NSDictionary *model;
@property (nonatomic, strong) NSDictionary *newsDetail;

@end
