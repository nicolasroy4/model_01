//
//  Macros.h
//  Movie
//
//  Created by Nicolas Roy on 09/06/13.
//  Copyright (c) 2013 Nicolas Roy. All rights reserved.
//

#ifndef Movie_Macros_h
#define Movie_Macros_h

#define S_UTF8(value) [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
#define S(format, ...) [NSString stringWithFormat:format,##__VA_ARGS__]
#define ISNULL(value) [value isEqual:[NSNull null]]
#define NSL(...) NSLog(@"%@",##__VA_ARGS__)


#endif
