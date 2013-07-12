//
//  NewsListCell.m
//  Movie
//
//  Created by Nicolas ROY on 10/07/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "NewsListCell.h"

@interface NewsListCell ()


@end

@implementation NewsListCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        if (self.isTop) self.backgroundColor = PATTERN(@"CellViewNewsBigBg_highlighted");
        else self.backgroundColor = PATTERN(@"CellViewNewsBg_highlighted");
        labelDate.textColor = [UIColor whiteColor];
        labelTitle.textColor = [UIColor whiteColor];
    } else {
        if (self.isTop) self.backgroundColor = PATTERN(@"CellViewNewsBigBg");
        else self.backgroundColor = PATTERN(@"CellViewNewsBigBg");
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
    
    [self downloadImageWithURL:[NSURL URLWithString:myNews[@"img"]] completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            self.newsImageView.image = image;
        }
    }];
    
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

@end
