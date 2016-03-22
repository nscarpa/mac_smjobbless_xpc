//
//  JobBlesser.h
//  osx_smjobbless_xpc
//
//  Created by Studio on 22/03/16.
//  Copyright © 2016 Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JobBlesser : NSObject

- (BOOL)blessHelperWithLabel:(NSString *)label error:(NSError **)errorPtr;

@end
