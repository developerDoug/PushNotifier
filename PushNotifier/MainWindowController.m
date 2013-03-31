//
//  MainWindowController.m
//  PushNotifier
//
//  Created by Doug Mason on 3/29/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import "MainWindowController.h"
#import "CertViewController.h"
#import "DetailViewController.h"

@interface MainWindowController ()
{
    CertViewController* _certController;
    DetailViewController* _detailController;
}

@end

@implementation MainWindowController

- (void)dealloc
{
    [_certController release];
    [_detailController release];
    [super dealloc];
}

- (id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window])
    {
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    CertViewController* certController = [[CertViewController alloc] init];
    DetailViewController* detailController = [[DetailViewController alloc] init];
    certController.delegate = detailController;
    detailController.delegate = certController;
    _certController = certController;
    _detailController = detailController;
    
    certController.view.frame = _topView.frame;
    detailController.view.frame = _bottomView.frame;
    
    [_topView addSubview:certController.view];
    [_bottomView addSubview:detailController.view];
}

- (void)applicationWillTerminate
{
    [_certController disconnectButtonPressed:self];
}

@end
