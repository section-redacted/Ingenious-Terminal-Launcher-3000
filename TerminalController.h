//
//  TerminalController.h
//  IngeniousOpener
//
//  Created by Adam on 6/16/10.
//  Copyright 2010 Ingenious Construct. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Terminal.h"
#import "SystemEvents.h"

@interface TerminalController : NSObject {
	TerminalApplication *terminal;
	SystemEventsApplication *systemEvents;
}

@property (retain) TerminalApplication *terminal;
@property (retain) SystemEventsApplication *systemEvents;


// Opens a new terminal window and creates a tab for every userScript. Every tab is cd'd to the path.
- (void)newTerminalWindowAtPath:(NSString *)path tabScripts:(NSArray *)userScripts;

// Launches Terminal if it isn't already running, and switches focus to it.
// If Terminal is launched, the window that opens automatically will be closed.
- (void)activateOrLaunch;

@end
