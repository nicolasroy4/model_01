//
//  NewsListCell.m
//  Movie
//
//  Created by Nicolas ROY on 10/07/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "NewsListCell.h"

@implementation NewsListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
}

/*----------------------------------------------------------------------------*/
#pragma mark - Model
/*----------------------------------------------------------------------------*/

- (void)setNewsDetail:(NSDictionary *)myNews
{
    UIView *myBackViewH = [[UIView alloc] initWithFrame:self.frame];
    myBackViewH.backgroundColor = PATTERN(@"CellViewNewsBg_highlighted");
    self.selectedBackgroundView = myBackViewH;
    
    UIView *myBackView = [[UIView alloc] initWithFrame:self.frame];
    myBackView.backgroundColor = PATTERN(@"CellViewNewsBg");
    
    self.backgroundView = myBackView;
    
    labelDate.text = [[NSString stringWithFormat:@"%@ %@", [self dateFormat:myNews[@"date"]], myNews[@"hour"]] capitalizedString];
    labelTitle.text = myNews[@"title"];
    
    NSString *imageURL = myNews[@"img"];
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    newsImageView.image = [UIImage imageWithData:imageData];
    newsImageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (NSString*) dateFormat:(NSString*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // jour de la news
    NSDate *dateFromString = [dateFormatter dateFromString:date];
    NSInteger dateInt = [dateFromString timeIntervalSince1970];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate:[NSDate date]];
    
    [components setHour:-[components hour]];
    [components setMinute:-[components minute]];
    [components setSecond:-[components second]];
    // aujourd'hui
    NSDate *today = [cal dateByAddingComponents:components toDate:[NSDate date] options:0];
    NSInteger todayInt = [today timeIntervalSince1970];
    
    [components setHour:-24];
    [components setMinute:0];
    [components setSecond:0];
    // hier
    NSDate *yesterday = [cal dateByAddingComponents:components toDate:today options:0];
    NSInteger yesterdayInt = [yesterday timeIntervalSince1970];
    
    NSString *strDate;
    
    if (dateInt == todayInt) {
        strDate = @"aujourd'hui";
    } else if (dateInt == yesterdayInt) {
        strDate = @"hier";
    } else {
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"EEEE dd MMMM";
        [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"fr_FR"]];
        strDate = [df stringFromDate:dateFromString] ;
    }
    
    return strDate;
}

@end
