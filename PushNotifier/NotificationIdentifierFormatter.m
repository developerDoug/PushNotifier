//
//  NotificationIdentifierFormatter.m
//  PushNotifier
//
//  Created by Doug Mason on 3/31/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import "NotificationIdentifierFormatter.h"
#import "NSString+RegexUtilities.h"

@implementation NotificationIdentifierFormatter

+ (NSArray*)arrayForString:(NSString *)str
{
    NotificationIdentifierFormatter* formatter = [[NotificationIdentifierFormatter alloc] init];
    return [formatter arrayForString:str];
}

- (NSArray*)arrayForString:(NSString*)str
{
    NSArray* matches = [str groupsForMatchesForRegex:@"([a-zA-Z0-9]{8})( |-)?([a-zA-Z0-9]{8})( |-)?([a-zA-Z0-9]{8})( |-)?([a-zA-Z0-9]{8})( |-)?([a-zA-Z0-9]{8})( |-)?([a-zA-Z0-9]{8})( |-)?([a-zA-Z0-9]{8})( |-)?([a-zA-Z0-9]{8})"
                                             options:NSRegularExpressionCaseInsensitive
                                  ignoringFirstGroup:YES];
    
    NSArray* groups = [matches objectAtIndex:0];
    unsigned int number[8] = { 0, 0, 0, 0, 0, 0, 0, 0 };
    
    NSMutableString* string = [NSMutableString string];
    for (int i = 0; i<groups.count; i++) {
        NSString* group = [groups objectAtIndex:i];
        [string appendString:group];
        if (i != groups.count-1)
            [string appendString:@" "];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:[string lowercaseString]];
    
    NSUInteger index = 0;
    
    while (![scanner isAtEnd] && (index < 8))
    {
        if (![scanner scanHexInt:&number[index++]])
        {
            break;
        }
    }
    
    return [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInt:number[0]],
			[NSNumber numberWithUnsignedInt:number[1]],
			[NSNumber numberWithUnsignedInt:number[2]],
			[NSNumber numberWithUnsignedInt:number[3]],
			[NSNumber numberWithUnsignedInt:number[4]],
			[NSNumber numberWithUnsignedInt:number[5]],
			[NSNumber numberWithUnsignedInt:number[6]],
			[NSNumber numberWithUnsignedInt:number[7]],
			nil];
}

@end
