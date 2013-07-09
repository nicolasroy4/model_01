//
//  NetworkEngine.h
//  Movie
//
//  Created by Nicolas Roy on 09/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "MKNetworkEngine.h"

@interface NetworkEngine : MKNetworkEngine

+ (MKNetworkEngine *)shared;

+ (MKNetworkOperation *)operationWithURL:(NSString *)url
                                  params:(NSDictionary *)params;

+ (MKNetworkOperation *)operationWithURL:(NSString *)url
                                  params:(NSDictionary *)params
                                  method:(NSString *)httpMethod;
@end
