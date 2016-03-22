//
//  AppDelegate.m
//  osx_smjobbless_xpc
//
//  Created by Studio on 22/03/16.
//  Copyright © 2016 Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "JobBlesser.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    JobBlesser *jobBlesser = [[JobBlesser alloc] init];
    
    NSError *error = nil;
    BOOL result = NO;

    result = [jobBlesser blessHelperWithLabel:@"it.nicoloscarpa.studio.privileged-helper" error:&error];
    
    if (!result) {
        NSLog(@"Something went wrong! %@ / %d", [error domain], (int) [error code]);
        
        return;
    }
    
    NSLog(@"Job is available!");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
