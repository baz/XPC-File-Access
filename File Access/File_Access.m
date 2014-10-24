//
//  File_Access.m
//  File Access
//
//  Created by Basil Shkara on 24/10/2014.
//  Copyright (c) 2014 Basil Shkara. All rights reserved.
//

#import "File_Access.h"
#import "File_AccessResponderProtocol.h"

@implementation File_Access

- (void)iterateSecureDirectoryURLWithReply:(void (^)())reply {
	// Ask the main app for the bookmark URL so we can iterate
	[self.connection.remoteObjectProxy secureBookmarkDataWithReply:^(NSData *newBookmarkData) {
		NSError *error = nil;
		BOOL stale = NO;
		NSURL *URL = [NSURL URLByResolvingBookmarkData:newBookmarkData options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&stale error:&error];

		BOOL success = [URL startAccessingSecurityScopedResource];

		NSLog(@"%@ %@ %d", URL, error, stale);

		NSLog(@"Able to access security scoped resource: %d", success);

		if (success) {
			NSFileManager *fileManager = [[NSFileManager alloc] init];
			NSArray *commonProperties = @[ NSURLLocalizedNameKey, NSURLCreationDateKey, NSURLContentModificationDateKey ];
			NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:URL includingPropertiesForKeys:commonProperties options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
			[enumerator skipDescendants];
	
			for (NSURL *fileURL in enumerator) {
				NSString *fileName = nil;
				[fileURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
	
				NSLog(@"FILE CAN BE READ %@",fileName);
			}
			[URL stopAccessingSecurityScopedResource];
		}

		// Finished
		reply();
	}];
}

@end
