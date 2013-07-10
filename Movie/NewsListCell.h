//
//  NewsListCell.h
//  Movie
//
//  Created by Nicolas ROY on 10/07/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsListCell : UITableViewCell
{
    IBOutlet UIImageView *newsImageView;
    IBOutlet UILabel *labelDate;
    IBOutlet UILabel *labelTitle;
}

@property (nonatomic, strong) NSDictionary *newsDetail;

@end
