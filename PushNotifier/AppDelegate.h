//
//  AppDelegate.h
//  PushNotifier
//
//  Created by Doug Mason on 3/27/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextFieldDelegate>
{
    IBOutlet NSTextField *_tokenField;
    IBOutlet NSTextField *_payloadField;
}

@property (assign) IBOutlet NSWindow *window;

@end
