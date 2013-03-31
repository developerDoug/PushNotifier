//
//  NSControl+Utilities.m
//  PushNotifier
//
//  Created by Doug Mason on 3/31/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import "NSTextField+Utilities.h"

@implementation NSTextField (Utilities)

- (BOOL)hasContent
{
    return ![self.stringValue isEqualToString:@""];
}

@end
