//
//  DetailViewController.m
//  PushNotifier
//
//  Created by Doug Mason on 3/29/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import "DetailViewController.h"
#import "NotificationIdentifierFormatter.h"
#import "AsyncSocket.h"
#import "NSTextField+Utilities.h"

@interface DetailViewController ()
{
    NSMutableArray* _notificationIDs;
    NSMutableArray* _customDataValues;
}
- (void)generatePayloadString;
@end

@implementation DetailViewController

- (void)dealloc
{
    [_notificationTableView release];
    [_alertTextField release];
    [_badgeCheckboxButton release];
    [_badgeTextField release];
    [_soundCheckboxButton release];
    [_soundTextField release];
    [_contentAvailableCheckboxButton release];
    [_customDataTableView release];
    [_sendNotificationTextView release];
    [_payloadSizeTextField release];
    [_sendButton release];
    [_addNotificationButton release];
    [_removeNotificationButton release];
    [_addCustomDataButton release];
    [_removeCustomDataButton release];
    [_notificationIDs release];
    [_customDataValues release];
    [super dealloc];
}

- (id)init
{
    if (self = [self initWithNibName:@"DetailViewController" bundle:nil])
    {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        _notificationIDs = [[NSMutableArray alloc] initWithCapacity:0];
        _customDataValues = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [_sendNotificationTextView setString:@""];
    [self buildPayload:NULL];
}

#pragma mark - NSTableView DataSource & Delegate Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (tableView == _notificationTableView)
        return _notificationIDs.count;
    else if (tableView == _customDataTableView)
        return _customDataValues.count;
    return 0;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSArray* array = nil;
    if (tableView == _notificationTableView)
        array = _notificationIDs;
    else if (tableView == _customDataTableView)
        array = _customDataValues;
    else
        return nil;
    
    return [[array objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSArray* array = nil;
    if (tableView == _notificationTableView)
        array = _notificationIDs;
    else if (tableView == _customDataTableView)
        array = _customDataValues;
    else
        return;
    
    [[array objectAtIndex:row] setObject:object forKey:[tableColumn identifier]];
    
    if (tableView == _customDataTableView)
        [self buildPayload:NULL];
}

#pragma mark - NSControl Delegate Methods

- (void)controlTextDidChange:(NSNotification *)obj
{
    [self buildPayload:NULL];
}

#pragma mark - CertViewControllerDelegate Methods

- (void)certViewControllerDidConnectSocket:(CertViewController *)controller 
{
    [_sendButton setEnabled:YES];
}

- (void)certViewControllerDidDisconnectSocket:(CertViewController *)controller
{
    [_sendButton setEnabled:NO];
}

#pragma mark - IBAction Methods

- (IBAction)sendButtonPressed:(id)sender
{
    for (NSDictionary* dictionary in _notificationIDs)
    {
        if (![[dictionary objectForKey:@"Selected"] boolValue])
            continue;
        
        NSString* notificationIdentifier = [dictionary objectForKey:@"NotificationID"];
        NSArray* formattedNotification = [NotificationIdentifierFormatter arrayForString:notificationIdentifier];
        NSData* output = [self buildSendData:formattedNotification];
        
		[self.delegate sendNotification:output];
    }
}

- (IBAction)badgeButtonPressed:(id)sender
{
    [_badgeTextField setStringValue:(_badgeCheckboxButton.state == NSOnState) ? @"0" : @""];
    [self buildPayload:NULL];
}

- (IBAction)soundButtonPressed:(id)sender
{
    [_soundTextField setStringValue:(_soundCheckboxButton.state == NSOnState) ? @"default" : @""];
    [self buildPayload:NULL];
}

- (IBAction)contentAvailableButtonPressed:(id)sender
{
    [self buildPayload:NULL];
}

- (IBAction)addNotificationIdButtonPressed:(id)sender
{
    [_notificationIDs addObject:[@{ @"Selected" : @(NO), @"Device" : @"?", @"NotificationID" : DEFAULT_NOTIFICATION_ID } mutableCopy]];
    [_removeNotificationButton setEnabled:YES];
    [_notificationTableView reloadData];
}

- (IBAction)removeNotificationIdButtonPressed:(id)sender
{
    if ([_notificationTableView selectedRow] >= 0)
    {
        [_notificationIDs removeObjectAtIndex:[_notificationTableView selectedRow]];
        [_removeNotificationButton setEnabled:(_notificationIDs.count == 0) ? NO : YES];
        [_notificationTableView reloadData];
    }
}

- (IBAction)addCustomDataButtonPressed:(id)sender
{
    [_customDataValues addObject:[@{ @"Key" : @"key", @"Value" : @"value" } mutableCopy]];
    [_removeCustomDataButton setEnabled:YES];
    [_customDataTableView reloadData];
    [self buildPayload:NULL];
}

- (IBAction)removeCustomDataButtonPressed:(id)sender
{
    if ([_customDataTableView selectedRow] >= 0)
    {
        [_customDataValues removeObjectAtIndex:[_customDataTableView selectedRow]];
        [_removeCustomDataButton setEnabled:(_customDataValues.count == 0) ? NO : YES];
        [_customDataTableView reloadData];
        [self buildPayload:NULL];
    }
}

#pragma mark - Private Methods

- (NSData*)buildSendData:(NSArray*)notificationID
{
    NSMutableData *output = [[NSMutableData alloc] init];
    NSMutableData *outputPayload = [[NSMutableData alloc] init];
    
    //	header
    char header[37];
    
    header[0] = 0;		//	fixed
    header[1] = 0;		//	fixed
    header[2] = 32;
    unsigned int* noteIds = (unsigned int*)&header[3];
    for (int i = 0; i < 8; i++)
    {
        NSNumber* number = [notificationID objectAtIndex:i];
        noteIds[i] = NSSwapInt([number intValue]);
    }
    header[35] = 0;		//	fixed
    header[36] = [self buildPayload:outputPayload];
    
    //	prepare output buffer
    [output appendBytes:header length:sizeof(header)];
    [output appendData:outputPayload];
    [outputPayload release];
    
    return [output autorelease];
}

- (NSUInteger)buildPayload:(NSMutableData*)data
{
    [self generatePayloadString];
    
    NSString* payload = _sendNotificationTextView.string;
    const char* payloadChar = [payload cStringUsingEncoding:NSUTF8StringEncoding];
    NSUInteger length = strlen(payloadChar);
    
    if (data)
        [data appendBytes:payloadChar length:length];
    
    //37 the size of the header.
    _payloadSizeTextField.stringValue = [NSString stringWithFormat:@"Payload Size : %ld / %d", length + 37, 255];
    
    return length;
}

- (void)generatePayloadString
{
    NSString* formatString = @"{\"aps\":%@}";
    
    NSMutableString* payload = [NSMutableString string];
    [payload appendString:@"{"];
    [payload appendString:([_alertTextField.stringValue isEqualToString:@""]) ? @"" : [NSString stringWithFormat:@"\"alert\":\"%@\"", _alertTextField.stringValue]];
    
    [payload appendString:(_badgeCheckboxButton.state == NSOffState) ? @"" :
     [NSString stringWithFormat:@"%@\"badge\":%d",
      ([_alertTextField hasContent]) ? @"," : @"", [_badgeTextField intValue]]];
    
    [payload appendString:(_soundCheckboxButton.state == NSOffState) ? @"" :
     [NSString stringWithFormat:@"%@\"sound\":\"%@\"",
      ([_alertTextField hasContent] || [_badgeTextField hasContent]) ? @"," : @"", _soundTextField.stringValue]];
    
    [payload appendString:(_contentAvailableCheckboxButton.state == NSOffState) ? @"" : [NSString stringWithFormat:@"%@\"content-available\":1", ([_alertTextField hasContent] || [_badgeTextField hasContent] || [_soundTextField hasContent]) ? @"," : @""]];
     
    [payload appendString:@"}"];
    [payload appendString:(_customDataValues.count > 0) ? @"," : @""];
    for (int i = 0; i < _customDataValues.count; i++)
    {
        NSDictionary* dictionary = [_customDataValues objectAtIndex:i];
        [payload appendFormat:@"\"%@\":\"%@\"", [dictionary objectForKey:@"Key"], [dictionary objectForKey:@"Value"]];
        
        if (i != _customDataValues.count-1)
            [payload appendString:@","];
    }
    
    _sendNotificationTextView.string = [NSString stringWithFormat:formatString, payload];
}

@end
