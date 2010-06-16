//
//  IngeniousOpenerAppDelegate.h
//  IngeniousOpener
//
//  Created by Adam on 6/16/10.
//  Copyright 2010 Ingenious Construct. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ApplicationController : NSObject <NSApplicationDelegate> {}

@property (assign) IBOutlet NSWindow *window;
@property (readonly, copy) NSString *path;
@property (readonly, copy) NSIndexSet *folderIndexSet;
@property (readonly, assign, getter=isNewFolder) BOOL newFolder;
@property (readonly, retain) NSDictionary *folder;
@property (assign) IBOutlet NSArrayController *foldersController;

// opens the terminal! who would've guessed
- (IBAction)openTerminal:(id)sender;

@end
