//
//  JobBlesser.m
//  osx_smjobbless_xpc
//
//  Created by Studio on 22/03/16.
//  Copyright © 2016 Studio. All rights reserved.
//

#import "JobBlesser.h"

#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

@implementation JobBlesser {
    AuthorizationRef _authRef;
}

- (id)init;
{
    self = [super init];
    
    if (self) {
        OSStatus status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &self->_authRef);
        if (errAuthorizationSuccess != status) {
            assert(NO);
            self->_authRef = NULL;
        }
    }
    
    return self;
}

- (BOOL)blessHelperWithLabel:(NSString *)label error:(NSError **)errorPtr;
{
    BOOL result = NO;
    NSError * error = nil;
    
    AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
    AuthorizationRights authRights	= { 1, &authItem };
    AuthorizationFlags flags		=	kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
    
    /* Obtain the right to install our privileged helper tool (kSMRightBlessPrivilegedHelper). */
    OSStatus status = AuthorizationCopyRights(self->_authRef, &authRights, kAuthorizationEmptyEnvironment, flags, NULL);
    if (status != errAuthorizationSuccess) {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    } else {
        CFErrorRef  cfError;
        
        /* This does all the work of verifying the helper tool against the application
         * and vice-versa. Once verification has passed, the embedded launchd.plist
         * is extracted and placed in /Library/LaunchDaemons and then loaded. The
         * executable is placed in /Library/PrivilegedHelperTools.
         */
        CFStringRef labelCFStringRef = (CFStringRef) CFBridgingRetain(label);
        result = (BOOL) SMJobBless(kSMDomainSystemLaunchd, labelCFStringRef, self->_authRef, &cfError);
        if (!result) {
            error = CFBridgingRelease(cfError);
        }
    }
    if ( ! result && (errorPtr != NULL) ) {
        assert(error != nil);
        *errorPtr = error;
    }
    
    return result;
}

@end
