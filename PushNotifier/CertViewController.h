//
//  CertViewController.h
//  PushNotifier
//
//  Created by Doug Mason on 3/30/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncSocket.h"
#import "DetailViewControllerDelegate.h"

@class AsyncSocket;
@class CertViewController;

@protocol CertViewControllerDelegate <NSObject>
- (void)certViewControllerDidConnectSocket:(CertViewController*)controller;
- (void)certViewControllerDidDisconnectSocket:(CertViewController*)controller;
@end

@interface CertViewController : NSViewController <NSComboBoxDataSource, NSComboBoxDelegate, AsyncSocketDelegate, DetailViewControllerDelegate>
{
    IBOutlet NSButton* _connectButton;
    IBOutlet NSButton* _disconnectButton;
    IBOutlet NSButton* _refreshComboBoxButton;
    IBOutlet NSComboBox* _certificateComboBox;
    AsyncSocket* _socketGateway;
    id<CertViewControllerDelegate> _delegate;
}

@property (nonatomic, assign) id<CertViewControllerDelegate> delegate;

- (IBAction)connectButtonPressed:(id)sender;
- (IBAction)disconnectButtonPressed:(id)sender;
- (IBAction)refreshComboBoxButtonPressed:(id)sender;

@end
