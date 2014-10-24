//
//  AppDelegate.m
//  test
//
//  Created by Basil Shkara on 15/10/2014.
//  Copyright (c) 2014 Basil Shkara. All rights reserved.
//

#import "AppDelegate.h"
#import "File_AccessProtocol.h"

static NSString *const kDataKey = @"Data";

@interface AppDelegate ()
	@property (weak) IBOutlet NSWindow *window;
	@property (nonatomic, strong) NSXPCConnection *connection;
@end

@implementation AppDelegate

- (IBAction)show:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	openPanel.allowsMultipleSelection = NO;
	openPanel.canChooseDirectories = YES;
	openPanel.canChooseFiles = NO;
	openPanel.canCreateDirectories = YES;
	openPanel.prompt = NSLocalizedString(@"Select", nil);

	__weak NSOpenPanel *weakPanel = openPanel;
	[openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			NSURL *selectedURL = [[weakPanel URLs] lastObject];

			// Create bookmark data
			NSData *data = [selectedURL bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope includingResourceValuesForKeys:nil relativeToURL:nil error:nil];

			[[NSUserDefaults standardUserDefaults] setObject:data forKey:kDataKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	}];
}

- (IBAction)log:(id)sender {
	NSXPCConnection *connection = [[NSXPCConnection alloc] initWithServiceName:@"io.neat.File-Access"];
	connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(File_AccessProtocol)];
	connection.exportedObject = self;
	connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(File_AccessResponderProtocol)];
	[connection resume];
	self.connection = connection;

	__weak AppDelegate *weakSelf = self;
	[[connection remoteObjectProxy] iterateSecureDirectoryURLWithReply:^{
		[weakSelf.connection invalidate];
	}];
}

- (void)secureBookmarkDataWithReply:(void (^)(NSData *))reply {
	NSData *previousData = [[NSUserDefaults standardUserDefaults] objectForKey:kDataKey];
	NSURL *bookmarkURL = nil;
	if (previousData) {
		bookmarkURL = [NSURL URLByResolvingBookmarkData:previousData options:NSURLBookmarkResolutionWithSecurityScope relativeToURL:nil bookmarkDataIsStale:NULL error:nil];

		NSLog(@"Previously saved URL: %@",bookmarkURL);

		// The URL above was just resolved with the app's security scope
		// In order for the XPC process to use this URL, we need to create another bookmark from this URL which does not have the security scope applied
		NSError *error = nil;
		NSData *newBookmarkData = [bookmarkURL bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
		[bookmarkURL stopAccessingSecurityScopedResource];

		reply(newBookmarkData);
	} else {
		NSLog(@"Nothing has been saved");

		reply(nil);
	}
}

@end
