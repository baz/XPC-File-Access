//
//  main.m
//  File Access
//
//  Created by Basil Shkara on 24/10/2014.
//  Copyright (c) 2014 Basil Shkara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "File_Access.h"
#import "File_AccessResponderProtocol.h"

@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
    // This method is where the NSXPCListener configures, accepts, and resumes a new incoming NSXPCConnection.
    
    // Configure the connection.
    // First, set the interface that the exported object implements.
    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(File_AccessProtocol)];
    
    // Next, set the object that the connection exports. All messages sent on the connection to this service will be sent to the exported object to handle. The connection retains the exported object.
    File_Access *exportedObject = [File_Access new];
    newConnection.exportedObject = exportedObject;

	// We'll take advantage of the bi-directional nature of NSXPCConnection to send changes back up to the caller
	// The remote side of this connection should implement the BeePluginObserver protocol
    newConnection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(File_AccessResponderProtocol)];
	exportedObject.connection = newConnection;
    
    // Resuming the connection allows the system to deliver more incoming messages.
    [newConnection resume];
    
    // Returning YES from this method tells the system that you have accepted this connection. If you want to reject the connection for some reason, call -invalidate on the connection and return NO.
    return YES;
}

@end

int main(int argc, const char *argv[])
{
    // Create the delegate for the service.
    ServiceDelegate *delegate = [ServiceDelegate new];
    
    // Set up the one NSXPCListener for this service. It will handle all incoming connections.
    NSXPCListener *listener = [NSXPCListener serviceListener];
    listener.delegate = delegate;
    
    // Resuming the serviceListener starts this service. This method does not return.
    [listener resume];
    return 0;
}
