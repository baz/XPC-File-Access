//
//  AppDelegate.h
//  test
//
//  Created by Basil Shkara on 15/10/2014.
//  Copyright (c) 2014 Basil Shkara. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "File_AccessResponderProtocol.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, File_AccessResponderProtocol>

- (IBAction)show:(id)sender;
- (IBAction)log:(id)sender;

@end

