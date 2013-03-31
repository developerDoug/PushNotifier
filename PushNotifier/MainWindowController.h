//
//  MainWindowController.h
//  PushNotifier
//
//  Created by Doug Mason on 3/29/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController
{
    IBOutlet NSView* _topView;
    IBOutlet NSView* _bottomView;
}

- (void)applicationWillTerminate;

@end
