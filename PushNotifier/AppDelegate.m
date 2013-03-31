//
//  AppDelegate.m
//  PushNotifier
//
//  Created by Doug Mason on 3/27/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()
{
    MainWindowController* _mainWindowController;
}
@end

@implementation AppDelegate

#pragma mark Allocation

- (id)init
{
	if((self = [super init]))
    {
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];    
}

- (void)awakeFromNib
{
    if (!_mainWindowController)
        _mainWindowController = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [_mainWindowController showWindow:self];
}

#pragma mark Inherent

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [_mainWindowController applicationWillTerminate];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)application
{
	return YES;
}

@end
