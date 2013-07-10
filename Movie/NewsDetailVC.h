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
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *contentView;
    
    IBOutlet UIWebView *webView;
    IBOutlet UILabel *labelTitle;
    IBOutlet UILabel *labelDate;
    IBOutlet UIImageView *newsImageView;
    IBOutlet UIButton *backButton;
}

@property (nonatomic, strong) NSDictionary *model;
@property (nonatomic, strong) NSDictionary *newsDetail;

@end
