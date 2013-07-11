//
//  NewsListBigCell.h
//  Movie
//
//  Created by Nicolas ROY on 11/07/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsListBigCell : UITableViewCell
{
    IBOutlet UILabel *labelDate;
    IBOutlet UILabel *labelTitle;
}

@property (nonatomic, strong) NSDictionary *newsDetail;
@property (strong, nonatomic) IBOutlet UIImageView *newsImageView;

@end
