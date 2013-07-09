//
//  NetworkEngine.m
//  Movie
//
//  Created by Nicolas Roy on 09/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "NetworkEngine.h"

@implementation NetworkEngine

+ (MKNetworkEngine *)shared
{
    static dispatch_once_t once;
    static MKNetworkEngine *instance;
    dispatch_once(&once, ^{
        instance = [[MKNetworkEngine alloc] init];
    });
    return instance;
}

+ (MKNetworkOperation *)operationWithURL:(NSString *)url params:(NSDictionary *)params
{
    return [self operationWithURL:url params:params method:@"GET"];
}

+ (MKNetworkOperation *)operationWithURL:(NSString *)url params:(NSDictionary *)params method:(NSString *)httpMethod
{
    MKNetworkOperation *op =
    [[NetworkEngine shared]
     operationWithURLString:url
     params:params
     httpMethod:httpMethod];
    
     [[MovieAPI shared] addAuthHeader:op];
    
    return op;
}

@end
