//
//  AppDelegate.m
//  osx_smjobbless_xpc
//
//  Created by Studio on 22/03/16.
//  Copyright © 2016 Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "JobBlesser.h"

NSString *const HelperLabel = @"it.nicoloscarpa.studio.privileged-helper";

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    JobBlesser *jobBlesser = [[JobBlesser alloc] init];
    
    NSError *error = nil;
    BOOL result = NO;

    result = [jobBlesser blessHelperWithLabel:HelperLabel error:&error];
    
    if (!result) {
        NSLog(@"Something went wrong! %@ / %d", [error domain], (int) [error code]);
        
        return;
    }
    
    NSLog(@"Job is available!");
    
    [self communicateWithHelper];
}

- (void)communicateWithHelper {
    const char* service_name = [HelperLabel UTF8String];
    
    xpc_connection_t connection = xpc_connection_create_mach_service(service_name, NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    
    if (!connection) {
        NSLog(@"Failed to create XPC connection.");
        
        return;
    }
    
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);
        
        if (type == XPC_TYPE_ERROR) {
            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
                NSLog(@"XPC connection interupted.");
            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
                NSLog(@"XPC connection invalid, releasing.");
                // xpc_release(connection); // not allowed in ARC
            } else {
                NSLog(@"Unexpected XPC connection error.");
            }
        } else {
            NSLog(@"Unexpected XPC connection event.");
        }
    });
    
    xpc_connection_resume(connection);
    
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    const char* request = "Hi there, helper service.";
    xpc_dictionary_set_string(message, "request", request);
    
    NSLog(@"%@", [NSString stringWithFormat:@"Sending request: %s", request]);
    
    xpc_connection_send_message_with_reply(connection, message, dispatch_get_main_queue(), ^(xpc_object_t reply) {
        const char* response = xpc_dictionary_get_string(reply, "response");
        NSLog(@"%@", [NSString stringWithFormat:@"Received response: %s.", response]);
    });
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
