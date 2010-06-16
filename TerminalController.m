//
//  TerminalController.m
//  IngeniousOpener
//
//  Created by Adam on 6/16/10.
//  Copyright 2010 Ingenious Construct. All rights reserved.
//

#import "TerminalController.h"

inline static void TerminalControllerOpenTab(NSString *script, TerminalWindow *window, TerminalApplication *application) {
    
}

@implementation TerminalController

@synthesize terminal;
@synthesize systemEvents;

- (TerminalController *)init {
	if(![super init])
		return nil;
	
	terminal = [[SBApplication alloc] initWithBundleIdentifier:@"com.apple.Terminal"];
	systemEvents = [[SBApplication alloc] initWithBundleIdentifier:@"com.apple.systemevents"];
	
	return self;
}

- (void)newTerminalWindowAtPath:(NSString *)path tabScripts:(NSArray *)userScripts {
    NSParameterAssert([userScripts count] >= 1);
    
    [self activateOrLaunch];
    
    TerminalApplication *term = [self terminal];
    SystemEventsApplication *sysEvents = [self systemEvents];
    NSString *cdScript = [[NSString alloc] initWithFormat:@"cd \"%@\"; clear", path];
    NSArray *originalWindows = [[term windows] get];
    TerminalWindow *currentWindow = nil;
    
    [term doScript:@"" in:nil]; // creates a new window
    
    // find the window we just created
    for(TerminalWindow *aWindow in [term windows]) {
        if(![originalWindows containsObject:aWindow]) {
            currentWindow = aWindow;
            break;
        }
    }
    
    NSAssert(currentWindow != nil, @"Shouldn't happen."); // TODO: handle this as an error.
    
    // For every userScript handed to us, send terminal CMD+T and then run the cd code as well as the script.
    // It's worth noting that this wouldn't be necessary if the AppleScript dictionary for Terminal actually _worked_.
    for(NSString *userScript in userScripts) {
        [sysEvents keystroke:@"t" using:SystemEventsEMdsCommandDown];
        [term doScript:cdScript in:currentWindow];
        [term doScript:userScript in:currentWindow];
    }
    
    // Close the first tab we created.
    SBElementArray *tabs = [currentWindow tabs];
    [[tabs objectAtIndex:0] setSelected:YES];
    [sysEvents keystroke:@"w" using:SystemEventsEMdsCommandDown];
    [[tabs objectAtIndex:([tabs count] -1)] setSelected:YES];
    
    [cdScript release];
}

- (void)activateOrLaunch {
	TerminalApplication *app = [self terminal];
	if([app isRunning]) {
		[app activate];
	} else {
		[app activate];
		[[[app windows] objectAtIndex:0] closeSaving:TerminalSaveOptionsNo savingIn:nil];
	}
}

- (void)dealloc {
	[terminal release];
	[super dealloc];
}

@end