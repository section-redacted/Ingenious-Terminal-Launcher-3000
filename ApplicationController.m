//
//  IngeniousOpenerAppDelegate.m
//  IngeniousOpener
//
//  Created by Adam on 6/16/10.
//  Copyright 2010 Ingenious Construct. All rights reserved.
//

#import "ApplicationController.h"
#import "TerminalController.h"
#import "Finder.h"


// getPathToFrontFinderWindow originally by James Tuley
// (though his version throws an exception when no Finder windows are open)
NSString* getPathToFrontFinderWindow() {
	
	FinderApplication* finder = [SBApplication applicationWithBundleIdentifier:@"com.apple.Finder"];
    
	
	
	FinderFinderWindow* frontWindow =[[finder windows]  objectAtIndex:0];
	
	FinderItem* target =  [frontWindow.properties objectForKey:@"target"] ;
    
    if(!target) // return path to desktop if no window exists
        return [@"~/Desktop" stringByExpandingTildeInPath];
	
	NSURL* url =[NSURL URLWithString:target.URL];
	
	FSRef fsRef;
	Boolean isDir =NO;
	Boolean wasAliased;
	if (CFURLGetFSRef((CFURLRef)url, &fsRef)){
		if (FSResolveAliasFile (&fsRef, true /*resolveAliasChains*/,
                                &isDir, &wasAliased) == noErr && wasAliased){
			NSURL* newURL = (NSURL*)CFURLCreateFromFSRef(NULL, &fsRef);
			[newURL autorelease];
			if(newURL!=nil)
				url = newURL;
		}
	}
    
	NSString* path = [url path];
    
	if(!isDir) {
		path = [path stringByDeletingLastPathComponent];
	}
    
	return path;
}

@interface ApplicationController ()

@property (readwrite, copy) NSString *path;
@property (readwrite, copy) NSIndexSet *folderIndexSet;
@property (readwrite, assign, getter=isNewFolder) BOOL newFolder;

@end


@implementation ApplicationController

@synthesize window, path, folderIndexSet, newFolder, foldersController;

#pragma mark Actions

- (IBAction)openTerminal:(id)sender {
    TerminalController *controller = [[TerminalController alloc] init];
    
    NSArray *folderScripts = [self.folder objectForKey:@"userScripts"];
    NSMutableArray *scripts = [NSMutableArray arrayWithCapacity:[folderScripts count]];
    
    for(NSDictionary *folderScript in folderScripts) {
        [scripts addObject:[folderScript objectForKey:@"script"]];
    }
    
    [controller newTerminalWindowAtPath:[self.folder objectForKey:@"path"] tabScripts:scripts];
    [controller release];
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark Properties

// I feel like there _has_ to be a better way to handle this than this insanity...
- (NSDictionary *)folder {
    return [[self.foldersController arrangedObjects] objectAtIndex:[self.folderIndexSet firstIndex]];
}

#pragma mark Internal

+ (void)initialize {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // The scripts are just defaults, by the way. When we find a new folder, these are copied, but that's about it for them.
    NSArray *scripts = [NSArray arrayWithObjects:
                        [NSDictionary dictionaryWithObject:@"" forKey:@"script"],
                        [NSDictionary dictionaryWithObject:@"ls -lh" forKey:@"script"],
                        nil];
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
                                 scripts, @"userScripts",
                                 nil];
    
    [defaults registerDefaults:appDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.newFolder = YES;
    self.path = getPathToFrontFinderWindow();
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *folders = nil;
    NSDictionary *currentFolder = nil;
    
    // find out whether we know this folder or not
    // this could probably be simplified and better and cleaner, but screw it, but there's only so much time i'm spending on this
    if( (folders = [defaults mutableArrayValueForKey:@"folders"]) && [folders count] != 0) {
        // well, we know some folders, that's a start
        for(NSDictionary *aFolder in folders) {
            if([[aFolder objectForKey:@"path"] isEqualToString:self.path]) {
                currentFolder = aFolder;
                break;
            }
        }
        
        if(currentFolder) { // cool, so we know this one! excellent
            self.newFolder = NO;
            self.folderIndexSet = [NSIndexSet indexSetWithIndex:[folders indexOfObject:currentFolder]];
        } else { // new folder, set it up
            NSArray *defaultScripts = [defaults arrayForKey:@"userScripts"];
            currentFolder = [NSDictionary dictionaryWithObjectsAndKeys:defaultScripts, @"userScripts", self.path, @"path", nil];
            [folders addObject:currentFolder];
            [defaults setValue:folders forKey:@"folders"];
            [defaults synchronize];
            self.folderIndexSet = [NSIndexSet indexSetWithIndex:[folders indexOfObject:currentFolder]];
        }
        
    } else { // no folders known - must be our first run
        NSArray *defaultScripts = [defaults arrayForKey:@"userScripts"];
        currentFolder = [NSDictionary dictionaryWithObjectsAndKeys:defaultScripts, @"userScripts", self.path, @"path", nil];
        folders = [NSMutableArray arrayWithObject:currentFolder];
        [defaults setValue:folders forKey:@"folders"];
        [defaults synchronize];
        self.folderIndexSet = [NSIndexSet indexSetWithIndex:0];
    }
    
    //if(newFolder)
        [window makeKeyAndOrderFront:self];
    //else
        //[self openTerminal:nil];
    
}

@end
