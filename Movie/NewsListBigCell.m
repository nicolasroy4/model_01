//
//  NewsListBigCell.m
//  Movie
//
//  Created by Nicolas ROY on 11/07/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "NewsListBigCell.h"

@implementation NewsListBigCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.backgroundColor = PATTERN(@"CellViewNewsBigBg_highlighted");
        labelDate.textColor = [UIColor whiteColor];
        labelTitle.textColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = PATTERN(@"CellViewNewsBigBg");
        labelDate.textColor = COLOR_DARK_GRAY;
        labelTitle.textColor = COLOR_BLACK;
    }
    
}

/*----------------------------------------------------------------------------*/
#pragma mark - Model
/*----------------------------------------------------------------------------*/

- (void)setNewsDetail:(NSDictionary *)myNews
{
    
    labelDate.text = [[NSString stringWithFormat:@"%@ %@", [DateHelper dateFormat:myNews[@"date"]], myNews[@"hour"]] capitalizedString];
    labelTitle.text = myNews[@"title"];
    
}

@end
