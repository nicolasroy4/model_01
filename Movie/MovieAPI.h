//
//  MovieAPI.h
//  Movie
//
//  Created by Nicolas Roy on 09/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum DataType : NSInteger {
    DataTypeObject,
    DataTypeArray,
    DataTypeDict
} DataType;

@interface MovieAPI : NSObject

+ (MovieAPI *)shared;

- (void)addAuthHeader:(id)request;

+ (NSString *)images:(NSNumber *)uid;
+ (NSString *)topMovies:(NSNumber*) total_pages;

+ (NSArray *)parseImages:(id)data;
+ (NSDictionary *)parseTopMovies:(id)data;

@end
