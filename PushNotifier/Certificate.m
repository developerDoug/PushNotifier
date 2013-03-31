//
//  Certificate.m
//  PushNotifier
//
//  Created by Doug Mason on 3/29/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import "Certificate.h"

@implementation Certificate

@synthesize key = _key;
@synthesize name = _name;
@synthesize identity = _identity;
@synthesize forIOS = _forIOS;

- (void)dealloc
{
    [_key release];
    [_name release];
    CFRelease(_identity);
    [super dealloc];
}

- (id)initCertificateWithKey:(NSString *)key name:(NSString *)name isForIOS:(BOOL)forIOS andIdentity:(SecIdentityRef)identity
{
    if (self = [super init])
    {
        _key = [key copy];
        _name = [name copy];
        _identity = identity;
        CFRetain(_identity);
        _forIOS = forIOS;
    }
    return self;
}

+ (id)certificateWithKey:(NSString *)key name:(NSString *)name isForIOS:(BOOL)forIOS andIdentity:(SecIdentityRef)identity
{
    return [[[self alloc] initCertificateWithKey:key name:name isForIOS:forIOS andIdentity:identity] autorelease];
}

- (NSString*)description
{
    NSString* stringToRemove = (self.isForIOS) ? APNS_DEVELOPMENT_IOS : APNS_DEVELOPMENT;
    NSRange range = [_key rangeOfString:stringToRemove];
    return [NSString stringWithFormat:@"%@ for %@", [_key substringFromIndex:range.length + 2], _name];
}

- (BOOL)isForIOS
{
    return _forIOS;
}

@end
