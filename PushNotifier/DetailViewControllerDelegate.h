//
//  DetailViewControllerDelegate.h
//  PushNotifier
//
//  Created by Doug Mason on 3/31/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DetailViewControllerDelegate <NSObject>
- (void)sendNotification:(NSData*)output;
@end
