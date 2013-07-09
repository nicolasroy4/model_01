//
//  MovieAPI.m
//  Movie
//
//  Created by Nicolas Roy on 09/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "MovieAPI.h"

@interface MovieAPI ()

@property (nonatomic, strong) NSString *key;

@end

@implementation MovieAPI


/*----------------------------------------------------------------------------*/
#pragma mark - Shared instance
/*----------------------------------------------------------------------------*/

static MovieAPI *sharedInstance = nil;

+ (MovieAPI *)shared
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
    NSString *domain = @"api.themoviedb.org";
    return  [NSString stringWithFormat:@"%@://%@/3/", protocol, domain];
}

- (NSString *)controller:(NSString *)controller
               arguments:(NSDictionary *)arguments
{
    NSMutableString *apiURL = [self baseURL].mutableCopy;
    
    [apiURL appendString:controller];
    [apiURL appendString:@"?api_key="];
    [apiURL appendString:self.key];

    
    if (arguments.count) {
        
        for (NSString *key in arguments.allKeys) {
            
            id arg = arguments[key];
            if (!arg || arg == [NSNull null]) continue;
            
            NSString *s = [MovieAPI objectToString:arg];
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
            
            NSString *s = [MovieAPI objectToString:o];
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

+ (NSString *)images:(NSNumber *)uid
{
    return [[MovieAPI shared]
            controller:S(@"movie/%d/images",uid.integerValue)
            arguments:nil];
}

+ (NSString *)topMovies:(NSNumber*) page
{
    NSDictionary *args = @{@"page": page,
                           @"vote_count.gte": @"50",
                           @"vote_average.gte":@"8.0",
                           @"release_date.gte": @"1990-01-01"};
    
    return [[MovieAPI shared]
            controller:S(@"discover/movie")
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


+ (NSDictionary *)parseTopMovies:(id)data
{
    
    NSDictionary *rawObjects = [self parseJSONString:data];
    
    NSArray *myData = rawObjects[@"results"];
    if (!myData) {
        // parsing error
        return nil;
    }
    
    @try {
        
        NSMutableArray *moviesId = [[NSMutableArray alloc] init];
        for (NSDictionary *movieInfo in myData) {
            NSString *filePath = [movieInfo objectForKey:@"id"];
            [moviesId addObject:filePath];
        }
        
        NSMutableDictionary *topMoviesInfo = [[NSMutableDictionary alloc] init];
        
        [topMoviesInfo setObject:rawObjects[@"total_pages"] forKey:@"total_pages"];
        [topMoviesInfo setObject:moviesId forKey:@"movies"];

        return topMoviesInfo;
    }
    @catch (NSException *exception) {
        return nil;
    }
}


+ (NSArray *)parseImages:(id)data
{
    
    NSDictionary *rawObjects = [self parseJSONString:data];

    NSArray *myData = [rawObjects objectForKey:@"backdrops"];
    if (!myData) {
        // parsing error
        return nil;
    }
    
    @try {
        
        NSMutableArray *files = [[NSMutableArray alloc] init];
        for (NSDictionary *imageInfo in myData) {
            NSString *filePath = [imageInfo objectForKey:@"file_path"];
            [files addObject:filePath];
        }
        
        return files;
    }
    @catch (NSException *exception) {
        return nil;
    }
}


@end
