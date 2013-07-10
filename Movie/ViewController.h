//
//  ViewController.h
//  Movie
//
//  Created by Nicolas Roy on 08/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MKHorizMenu;
@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView *newsListTableView;
    IBOutlet UIView *footerView;
    IBOutlet UIButton *buttonLoadMore;

}
@property (nonatomic, strong) IBOutlet MKHorizMenu *horizMenu;
@property (nonatomic, strong) NSArray* model;

@end
