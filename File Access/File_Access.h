//
//  File_Access.h
//  File Access
//
//  Created by Basil Shkara on 24/10/2014.
//  Copyright (c) 2014 Basil Shkara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File_AccessProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface File_Access : NSObject <File_AccessProtocol>

@property (nonatomic, weak) NSXPCConnection *connection;

@end
