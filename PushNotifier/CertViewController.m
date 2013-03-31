//
//  CertViewController.m
//  PushNotifier
//
//  Created by Doug Mason on 3/30/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import "CertViewController.h"
#import "Certificate.h"

@interface CertViewController ()
{
    Certificate* _currentCertificate;
    NSMutableArray* _certificates;
}
- (NSArray*)certificatesForKeychain:(SecKeychainRef)keychainRef;
- (void)loadCertificates;
- (void)loadCertificatesEnumerateForEach:(void (^)(NSString* commonName, NSString* name, BOOL isForIOS, SecIdentityRef identityRef))foundCert;
- (NSString *)getStringAttribute:(SecKeychainAttrType)aAttribute ofItem:(SecKeyRef)aItem;
- (NSData *)getAttribute:(SecKeychainAttrType)aAttribute ofItem:(SecKeyRef)aItem;
@end

@implementation CertViewController

@synthesize delegate = _delegate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_certificates release];
    [super dealloc];
}

- (id)init
{
    if (self = [self initWithNibName:@"CertViewController" bundle:nil])
    {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        _certificates = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(comboBoxSelectionDidChange:)
                                                     name:NSComboBoxSelectionDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    [self loadCertificates];
}

#pragma mark - NSComboBox DataSource & Delegate Methods

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return _certificates.count;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	NSInteger index = _certificateComboBox.indexOfSelectedItem;
	_currentCertificate = (index >= 0) ? [_certificates objectAtIndex:index] : nil;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
	return [[_certificates objectAtIndex:index] description];
}

#pragma mark - AsyncSocketDelegate Methods

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (sock == _socketGateway)
        NSLog(@"Socket Gateway Connected = %@, %d", host, port);
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    NSInteger index = [_certificateComboBox indexOfSelectedItem];
    if (index >= 0)
    {
        Certificate* cert = [_certificates objectAtIndex:index];
        SecIdentityRef identityRef = [cert identity];
        CFArrayRef arrayRef = CFArrayCreate(NULL, (const void**)&identityRef, 1, NULL);
        if (arrayRef)
        {
            [settings setObject:(NSArray*)arrayRef forKey:(NSString*)kCFStreamSSLCertificates];
            CFRelease(arrayRef);
        }
    }
    
    [self setEnableOfControls:NO];
    [_disconnectButton setEnabled:YES];
    [_refreshComboBoxButton setEnabled:YES];
    [_delegate certViewControllerDidConnectSocket:self];
    [sock startTLS:settings];
}

- (void)onSocketDidSecure:(AsyncSocket *)sock
{
    if (sock == _socketGateway)
    {
        [_socketGateway readDataWithTimeout:DEFAULT_TIMEOUT tag:0];
        NSLog(@"Socket Gateway Secured");
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (sock == _socketGateway)
    {
        NSLog(@"Socket Gateway Read");
        [_socketGateway readDataWithTimeout:DEFAULT_TIMEOUT tag:0];
    }
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(CFIndex)length
{
    return DEFAULT_TIMEOUT;
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    if (sock == _socketGateway)
        NSLog(@"Socket Gateway Error = %@", err);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    if (sock == _socketGateway)
    {
        [_socketGateway setDelegate:nil];
        [_socketGateway disconnect];
        [_socketGateway release];
        _socketGateway = nil;
        NSLog(@"Socket Gateway Terminated");
    }
}

#pragma mark - DetailViewControllerDelegate Methods

- (void)sendNotification:(NSData *)output
{
    [_socketGateway writeData:output withTimeout:DEFAULT_TIMEOUT tag:0];
}

#pragma mark - IBAction Methods

- (IBAction)connectButtonPressed:(id)sender
{
    if (!_socketGateway)
    {
        _socketGateway = [[AsyncSocket alloc] initWithDelegate:self];
        NSError* error = nil;
        if (![_socketGateway connectToHost:@"gateway.sandbox.push.apple.com" onPort:2195 error:&error])
        {
            [_socketGateway disconnect];
            [_socketGateway release];
            _socketGateway = nil;
            
            if (error)
                NSLog(@"Socket Gateway Error During Connect = %@", error);
        }
    }
}

- (IBAction)disconnectButtonPressed:(id)sender
{
    if (_socketGateway)
    {
        [_socketGateway disconnect];
        [_socketGateway release];
        _socketGateway = nil;
        [_delegate certViewControllerDidDisconnectSocket:self];
    }
    
    [self setEnableOfControls:YES];
}

- (IBAction)refreshComboBoxButtonPressed:(id)sender
{
    [self disconnectButtonPressed:self];
    [_delegate certViewControllerDidDisconnectSocket:self];
    [self loadCertificates];
}

#pragma mark - Private Methods

- (void)setEnableOfControls:(BOOL)enable
{
    [_connectButton setEnabled:enable];
    [_disconnectButton setEnabled:enable];
    [_refreshComboBoxButton setEnabled:enable];
}

- (NSArray*)certificatesForKeychain:(SecKeychainRef)keychainRef
{
    NSDictionary* query = @{ (id)kSecClass : (id)kSecClassCertificate,
                             (id)kSecMatchSearchList : @[ (id)keychainRef ],
                             (id)kSecReturnRef : (id)kCFBooleanTrue,
                             (id)kSecMatchLimit : (id)kSecMatchLimitAll };
    NSArray* items = nil;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef*)&items);
    if (status) {
        if (status != errSecItemNotFound)
            NSLog(@"Can't search keychain with status %d", status);
        return nil;
    }
    
    return items;
}

- (void)loadCertificates
{
    [_certificates removeAllObjects];
    
    [self loadCertificatesEnumerateForEach:^(NSString* commonName, NSString* name, BOOL isForIOS, SecIdentityRef identityRef) {
        [_certificates addObject:[Certificate certificateWithKey:commonName
                                                            name:name
                                                        isForIOS:isForIOS
                                                     andIdentity:identityRef]];
    }];
    
    [_certificateComboBox reloadData];
    [self setEnableOfControls:YES];
}

- (void)loadCertificatesEnumerateForEach:(void (^)(NSString* commonName, NSString* name, BOOL isForIOS, SecIdentityRef identityRef))foundCert
{
    SecKeychainRef keychainRef = nil;
    if (SecKeychainCopyDefault(&keychainRef) == noErr)
    {
        NSArray* certificateRefs = [self certificatesForKeychain:keychainRef];
        
        for (id certRef in certificateRefs)
        {
            SecCertificateRef certificateRef = (SecCertificateRef)certRef;
            CFStringRef commonName = nil;
            
            if (SecCertificateCopyCommonName(certificateRef, &commonName) == noErr)
            {
                BOOL includeCertificate = NO;
                includeCertificate = [(NSString*)commonName hasPrefix:APNS_DEVELOPMENT];
                BOOL forIOS = NO;
                
                if (!includeCertificate) {
                    includeCertificate = [(NSString*)commonName hasPrefix:APNS_DEVELOPMENT_IOS];
                    forIOS = YES;
                }
                
                if (includeCertificate)
                {
                    SecIdentityRef identityRef = nil;
                    SecKeyRef privateRef = nil;
                    
                    if (SecIdentityCreateWithCertificate(keychainRef, certificateRef, &identityRef) == noErr)
                    {
                        if (SecIdentityCopyPrivateKey(identityRef, &privateRef) == noErr)
                        {
                            NSString *name = [self getStringAttribute:kSecKeyPrintName ofItem:privateRef];
                            if (foundCert)
                                foundCert((NSString*)commonName, (NSString*)name, forIOS, identityRef);
                            CFRelease(privateRef);
                        }
                        CFRelease(identityRef);
                    }
                }
                CFRelease(commonName);
            }
        }
        [certificateRefs release];
        CFRelease(keychainRef);
    }
}

- (NSString *)getStringAttribute:(SecKeychainAttrType)aAttribute ofItem:(SecKeyRef)aItem
{
    NSData *value = [self getAttribute:aAttribute ofItem:aItem];
	
    if (value)
	{
		const char *bytes = value.bytes;
        
		size_t length = value.length;
		
		if ((length > 0) && (bytes[length - 1] == 0))
		{
			length--;
		}
		
		NSString *string = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
		
		return [string autorelease];
	}
	
	return nil;
}

- (NSData *)getAttribute:(SecKeychainAttrType)aAttribute ofItem:(SecKeyRef)aItem
{
    NSData *value = nil;
	
	UInt32 format = kSecFormatUnknown;
	
	SecKeychainAttributeInfo info = {.count = 1, .tag = (UInt32*)&aAttribute, .format = &format};
    
	SecKeychainAttributeList *list = NULL;
	
    if (SecKeychainItemCopyAttributesAndData((SecKeychainItemRef)aItem, &info, NULL, &list, NULL, NULL) == noErr)
	{
        if (list)
		{
            if (list->count == 1)
			{
                value = [NSData dataWithBytes:list->attr->data length:list->attr->length];
			}
			
            SecKeychainItemFreeAttributesAndData(list, NULL);
        }
    }
    
    return value;
}

@end
