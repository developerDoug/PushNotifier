//
//  NSString+RegexUtilities.h
//  PushNotifier
//
//  Created by Doug Mason on 3/31/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RegexUtilities)
- (NSArray*)groupsForMatchesForRegex:(NSString*)pattern options:(NSRegularExpressionOptions)options ignoringFirstGroup:(BOOL)ignore;
@end
