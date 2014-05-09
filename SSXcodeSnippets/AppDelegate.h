//
//  MLBLAppDelegate.h
//  SSXcodeSnippets
//
//  Created by sofiaswidarowicz on 15/04/14.
//  Copyright (c) 2014 phyline. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DropboxOSX/DropboxOSX.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>{
	DBRestClient *restClient;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *loginButton;
@property (assign) IBOutlet NSButton *retrieveSnippetsButton;
@property (assign) IBOutlet NSTextView *textViewSnippets;

- (IBAction)didPressLoginDropbox:(id)sender;
- (IBAction)didPressRetrieveSnippets:(id)sender;

@end
