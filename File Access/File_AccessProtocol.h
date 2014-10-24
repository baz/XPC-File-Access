//
//  File_AccessProtocol.h
//  File Access
//
//  Created by Basil Shkara on 24/10/2014.
//  Copyright (c) 2014 Basil Shkara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol File_AccessProtocol

- (void)iterateSecureDirectoryURLWithReply:(void (^)())reply;
    
@end
