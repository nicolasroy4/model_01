//
//  API.h
//  Movie
//
//  Created by Nicolas ROY on 10/07/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum DataType : NSInteger {
    DataTypeObject,
    DataTypeArray,
    DataTypeDict
} DataType;


@interface API : NSObject

+ (API *)shared;

- (void)addAuthHeader:(id)request;

+ (NSString *)newsListCount:(NSNumber *)count category:(NSNumber *)idCat;
+ (NSString *)newsDetail:(NSNumber *)idCat;

+ (NSArray *)parseNewsList:(id)data;
+ (NSDictionary *)parseNewsDetail:(id)data;

@end
