//
//  API.m
//  Movie
//
//  Created by Nicolas Roy on 09/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "API.h"

@interface API ()

@property (nonatomic, strong) NSString *key;

@end

@implementation API


/*----------------------------------------------------------------------------*/
#pragma mark - Shared instance
/*----------------------------------------------------------------------------*/

static API *sharedInstance = nil;

+ (API *)shared
{
    if (sharedInstance != nil) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


/*----------------------------------------------------------------------------*/
#pragma mark - Init/Dealloc
/*----------------------------------------------------------------------------*/

- (id)init
{
    self = [super init];
    if (self) {
        self.key = @"06df379bf63c944c4a2d1d043e36b5ec";
    }
    return self;
}



/*----------------------------------------------------------------------------*/
#pragma mark - API Access
/*----------------------------------------------------------------------------*/

- (void)addAuthHeader:(id)request
{
    [request addHeaders:@{@"accept":@"*/*"}];
}


/*----------------------------------------------------------------------------*/
#pragma mark - Server
/*----------------------------------------------------------------------------*/

- (NSString *)baseURL
{
    NSString *protocol = @"http";
    NSString *domain = @"api.programme-tv.net";
    return  [NSString stringWithFormat:@"%@://%@/1326279455-10/", protocol, domain];
}

- (NSString *)controller:(NSString *)controller
               arguments:(NSDictionary *)arguments
{
    NSMutableString *apiURL = [self baseURL].mutableCopy;
    
    [apiURL appendString:controller];
    [apiURL appendString:@"/?"];    
    
    if (arguments.count) {
        
        for (NSString *key in arguments.allKeys) {
            
            id arg = arguments[key];
            if (!arg || arg == [NSNull null]) continue;
            
            NSString *s = [API objectToString:arg];
            if (s) [apiURL appendFormat:@"&%@=%@",key,s];
        }
    }
    
    NSString *url = S_UTF8(apiURL);
    
    
    return url;
}


+ (NSString *)objectToString:(id)arg
{
    // string
    if ([arg isKindOfClass:[NSString class]]) {
        
        if (![(NSString *)arg length]) return nil;
        return arg;
    }
    
    // number to string
    if ([arg isKindOfClass:[NSNumber class]]) {
        return [(NSNumber *)arg stringValue];
    }
    
    // array to string
    if ([arg isKindOfClass:[NSArray class]]) {
        
        if (![(NSArray *)arg count]) return nil;
        
        NSMutableString *ms = [NSMutableString new];
        
        for (id o in arg) {
            
            NSString *s = [API objectToString:o];
            if (s) {
                if (ms.length) [ms appendString:@","];
                [ms appendString:s];
            }
        }
        
        return ms;
    }
    
    return nil;
}



/*----------------------------------------------------------------------------*/
#pragma mark - URLs
/*----------------------------------------------------------------------------*/

+ (NSString *)newsListCount:(NSNumber *)count category:(NSNumber *)idCat
{
    NSDictionary *args = @{@"count": count,
                           @"idCategory": idCat
                           };
    
    return [[API shared]
            controller:@"getNews"
            arguments:args];
}

+ (NSString *)newsDetail:(NSNumber *)idCat
{
    NSDictionary *args = @{@"id": idCat};
    
    return [[API shared]
            controller:@"getNews"
            arguments:args];
}

/*----------------------------------------------------------------------------*/
#pragma mark - Response
/*----------------------------------------------------------------------------*/

+ (id)parseJSONString: (NSString*) jsonString
{
    
    NSStringEncoding  encoding = NSUTF8StringEncoding;
    NSData * jsonData = [jsonString dataUsingEncoding:encoding];
    NSError * error=nil;
    
    
    NSDictionary * parsedData = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
    return parsedData;
}


+ (NSArray *)parseNewsList:(id)data
{
    NSDictionary *rawObjects = [self parseJSONString:data];
    
    @try {
        NSArray *myData = [rawObjects objectForKey:@"data"];
        return myData;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

+ (NSDictionary *)parseNewsDetail:(id)data
{
    NSDictionary *rawObjects = [self parseJSONString:data];
    
    @try {
        NSDictionary *myData = [rawObjects objectForKey:@"data"];
        return myData;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

@end
