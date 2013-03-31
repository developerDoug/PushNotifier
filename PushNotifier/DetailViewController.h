//
//  DetailViewController.h
//  PushNotifier
//
//  Created by Doug Mason on 3/29/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CertViewController.h"

@interface DetailViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, CertViewControllerDelegate>
{
    IBOutlet NSTableView* _notificationTableView;
    IBOutlet NSTextField* _alertTextField;
    IBOutlet NSButton* _badgeCheckboxButton;
    IBOutlet NSTextField* _badgeTextField;
    IBOutlet NSButton* _soundCheckboxButton;
    IBOutlet NSTextField* _soundTextField;
    IBOutlet NSButton* _contentAvailableCheckboxButton;
    IBOutlet NSTableView* _customDataTableView;
    IBOutlet NSTextView* _sendNotificationTextView;
    IBOutlet NSTextField* _payloadSizeTextField;
    IBOutlet NSButton* _sendButton;
    IBOutlet NSButton* _addNotificationButton;
    IBOutlet NSButton* _removeNotificationButton;
    IBOutlet NSButton* _addCustomDataButton;
    IBOutlet NSButton* _removeCustomDataButton;
    id<DetailViewControllerDelegate> _delegate;
}

@property (nonatomic, assign) id<DetailViewControllerDelegate> delegate;

- (IBAction)badgeButtonPressed:(id)sender;
- (IBAction)soundButtonPressed:(id)sender;
- (IBAction)contentAvailableButtonPressed:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;
- (IBAction)addNotificationIdButtonPressed:(id)sender;
- (IBAction)removeNotificationIdButtonPressed:(id)sender;
- (IBAction)addCustomDataButtonPressed:(id)sender;
- (IBAction)removeCustomDataButtonPressed:(id)sender;

@end
