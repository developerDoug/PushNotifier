//
//  NotificationIdentifierFormatter.h
//  PushNotifier
//
//  Created by Doug Mason on 3/31/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationIdentifierFormatter : NSObject
+ (NSArray*)arrayForString:(NSString*)str;
- (NSArray*)arrayForString:(NSString*)str;
@end
