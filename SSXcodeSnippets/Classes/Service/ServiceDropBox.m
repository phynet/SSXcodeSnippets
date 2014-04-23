//
//  ServiceDropBox.m
//  SSXcodeSnippets
//
//  Created by sofiaswidarowicz on 23/04/14.
//  Copyright (c) 2014 Media Net. All rights reserved.
//

#import "ServiceDropBox.h"
#import "Constants.h"


#define APP_KEY @"exytioa45pbf5of"
#define APP_SECRET @"pxqyt3gjgu2km7m"
#define URL_PATH @"~/Library/Developer/Xcode/UserData/CodeSnippets/"


@implementation ServiceDropBox

-(void)doLogin{

	NSString *appKey = APP_KEY;
    NSString *appSecret = APP_SECRET;
    NSString *root = kDBRootDropbox;

    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    [DBSession setSharedSession:session];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];


    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:)
		  forEventClass:kInternetEventClass andEventID:kAEGetURL];

}

- (void)authHelperStateChangedNotification:(NSNotification *)notification {
	[[NSNotificationCenter defaultCenter] postNotificationName:STATE_CHANGED object:nil];

}
- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    // This gets called when the user clicks Show "App name". You don't need to do anything for Dropbox here
}


@end
