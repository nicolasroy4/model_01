//
//  ViewController.m
//  Movie
//
//  Created by Nicolas Roy on 08/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) MKNetworkOperation *operation;
@property (nonatomic, strong) NSArray *imagesArray; // of file path
@property (nonatomic, strong) NSMutableArray *topMoviesArray; // of id
@property (nonatomic, strong) NSNumber *total_pages;
@property (nonatomic, strong) NSNumber *actual_page;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    tap.cancelsTouchesInView = YES;
    tap.numberOfTapsRequired = 1;
    //tap.delegate = self;
    
    movieImage.userInteractionEnabled = YES;
    [movieImage addGestureRecognizer:tap];
    
    [self loadTopMovies];

}

- (NSMutableArray *)topMoviesArray
{
    if (!_topMoviesArray) {
        _topMoviesArray = [[NSMutableArray alloc] init];
    }
    
    return _topMoviesArray;
}

- (NSNumber *)total_pages
{
    if (!_total_pages) {
        _total_pages = @1;
    }
    
    return _total_pages;
}

- (NSNumber *)actual_page
{
    if (!_actual_page) {
        _actual_page = @1;
    }
    
    return _actual_page;
}

- (void) handleImageTap:(UIGestureRecognizer *)gestureRecognizer {

    NSLog(@"%@ %@ %@", @([self.topMoviesArray count]), self.actual_page, self.total_pages);
    
    [self loadImages];
}

- (void)loadTopMovies
{
    // Arrêt des opérations en cours
    
    [self.operation cancel];
    self.operation = nil;
    
    
    // Requète + Paramètres
    
    if (self.actual_page < self.total_pages) {
        self.actual_page = @([self.actual_page integerValue] + 1);
    }
    
    NSLog(@"RELOAD");

    NSString *url = [MovieAPI topMovies: self.actual_page];
    
    self.operation = [NetworkEngine operationWithURL:url params:nil];
    
    // Execution + Handler
    
    __block ViewController *this = self;
    
    [self.operation addCompletionHandler:^(MKNetworkOperation *completedOp) {
        
      //  NSLog(@"%@", completedOp);
        
        [this loadDataTopMoviesCompletion:completedOp.responseString];
        [this setImage];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        
    }];
    
    [[NetworkEngine shared] enqueueOperation:self.operation forceReload:YES];
}

- (void)loadImages
{    
    // Arrêt des opérations en cours
    
    [self.operation cancel];
    self.operation = nil;
        
    
    // Requète + Paramètres
    
    NSNumber* movieId = self.topMoviesArray[0];
    NSString *url = [MovieAPI images:movieId];
    [self.topMoviesArray removeObjectAtIndex:0];
    
    self.operation = [NetworkEngine operationWithURL:url params:nil];
    
    // Execution + Handler
    
    __block ViewController *this = self;
    
    [self.operation addCompletionHandler:^(MKNetworkOperation *completedOp) {
        
     //   NSLog(@"%@", completedOp);
        
        [this loadDataImageCompletion:completedOp.responseString];
        [this setImage];
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        
    }];
    
    [[NetworkEngine shared] enqueueOperation:self.operation forceReload:YES];
}

- (void)loadDataTopMoviesCompletion:(NSString *)jsonString
{
    NSDictionary *topMoviesInfos = [MovieAPI parseTopMovies:jsonString];
    [self.topMoviesArray addObjectsFromArray:topMoviesInfos[@"movies"]];
    NSL(self.topMoviesArray);

    self.total_pages = topMoviesInfos[@"total_pages"];
}

- (void)loadDataImageCompletion:(NSString *)jsonString
{
    self.imagesArray = [MovieAPI parseImages:jsonString];
    if ([self.topMoviesArray count] < 4) {
        [self loadTopMovies];
    }

}

- (void)setImage
{
    NSString *imageURL = S(@"http://cf2.imgobject.com/t/p/w500/%@",self.imagesArray[0]);
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
    movieImage.image = [UIImage imageWithData:imageData];
    movieImage.contentMode = UIViewContentModeScaleAspectFit;
}

@end
