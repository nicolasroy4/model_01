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

#define PATTERN(image) [UIColor colorWithPatternImage:[UIImage imageNamed:image]]
#define IMG(image) [UIImage imageNamed:image]
#define STRETCH(image, width, height) [[UIImage imageNamed:image] stretchableImageWithLeftCapWidth:width topCapHeight:height]

#define C(r,g,b,a) [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a]
#define COLOR_BLACK      C( 48, 48, 48, 1)
#define COLOR_DARK_GRAY  C( 97, 97, 97, 1)
#endif
