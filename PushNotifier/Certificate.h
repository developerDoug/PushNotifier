//
//  Certificate.h
//  PushNotifier
//
//  Created by Doug Mason on 3/29/13.
//  Copyright (c) 2013 Doug Mason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Certificate : NSObject
{
    NSString* _key;
    NSString* _name;
    SecIdentityRef _identity;
    BOOL _forIOS;
}

@property (readonly) NSString* key;
@property (readonly) NSString* name;
@property (readonly) SecIdentityRef identity;
@property (readonly, getter = isForIOS) BOOL forIOS;

+ (id)certificateWithKey:(NSString*)key name:(NSString*)name isForIOS:(BOOL)forIOS andIdentity:(SecIdentityRef)identity;
- (id)initCertificateWithKey:(NSString*)key name:(NSString*)name isForIOS:(BOOL)forIOS andIdentity:(SecIdentityRef)identity;

@end
