//
//  NSString+RegexUtilities.m
//  PushNotifier
//
//  Created by Doug Mason on 3/31/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import "NSString+RegexUtilities.h"

@implementation NSString (RegexUtilities)

- (NSArray*)groupsForMatchesForRegex:(NSString*)pattern options:(NSRegularExpressionOptions)options ignoringFirstGroup:(BOOL)ignore
{
    NSMutableArray* matches = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSError* error = NULL;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
    
    if (error) goto FAIL;
    
    [regex enumerateMatchesInString:self
                            options:0
                              range:NSMakeRange(0, [self length])
                         usingBlock:^(NSTextCheckingResult* result, NSMatchingFlags flags, BOOL* stop) {
                             
                             NSMutableArray* groups = [[NSMutableArray alloc] init];
                             for (int i = 0; i < result.numberOfRanges; i++)
                             {
                                 if (i == 0 && ignore)
                                     continue;
                                 
                                 [groups addObject:[self substringWithRange:[result rangeAtIndex:i]]];
                             }
                             
                             [matches addObject:groups];
                         }];
    
    return matches;
    
FAIL:
    NSLog(@"Failed to compile regex.");
    return nil;
}

@end
