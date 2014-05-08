//
//  MLBLAppDelegate.m
//  SSXcodeSnippets
//
//  Created by sofiaswidarowicz on 15/04/14.
//  Copyright (c) 2014 Media Net. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxOSX/DropboxOSX.h>
#import <stdlib.h>
#import <time.h>
#import "Constants.h"


#define APP_KEY @"exytioa45pbf5of"
#define APP_SECRET @"pxqyt3gjgu2km7m"
#define URL_PATH @"~/Library/Developer/Xcode/UserData/CodeSnippets/"

@interface AppDelegate () <DBRestClientDelegate>

-(void)updateLoginButton;
-(NSString*)snippetsPathDropbox;
-(void)loadSnippets;
- (DBRestClient *)restClient;


@property (nonatomic, retain) NSString *requestToken;
@property (nonatomic, retain) NSArray *snippetsPaths;
@property (nonatomic, retain) NSString *snippetHash;
@property (nonatomic, copy) NSString *snippetPathSaved;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize loginButton = _loginButton;
@synthesize snippetsPaths;
@synthesize textViewSnippets;
@synthesize requestToken;
@synthesize retrieveSnippetsButton;
@synthesize snippetHash;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self callingService];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(verifyState) name:STATE_CHANGED object:nil];
	[self updateLoginButton];
	_snippetPathSaved = @"";
}
-(void)callingService
{
	[self doLogin];
}
-(void)verifyState{

	[self updateLoginButton];
    if ([[DBSession sharedSession] isLinked]) {
        // You can now start using the API!
        [self didPressRetrieveSnippets:nil];
    }
}

#pragma mark button

- (IBAction)didPressRetrieveSnippets:(id)sender {

	self.retrieveSnippetsButton.state = NSOffState;

    NSString *snippetsRoot = nil;
    if ([DBSession sharedSession].root == kDBRootDropbox) {
        snippetsRoot = @"/Snippets";
    } else {
        snippetsRoot = @"/";
    }

    [self.restClient loadMetadata:snippetsRoot withHash:self.snippetHash];
	
}
- (IBAction)didPressLoginDropbox:(id)sender {
	if ([[DBSession sharedSession] isLinked]) {
        // The link button turns into an unlink button when you're linked
        [[DBSession sharedSession] unlinkAll];
        restClient = nil;
        [self updateLoginButton];
    } else {

   	  [[DBAuthHelperOSX sharedHelper] authenticate];


    }

}
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
	//search data of type codesnippet from folder in dropbox
	self.snippetHash = metadata.hash;


    NSArray* validExtensions = [NSArray arrayWithObjects:@"codesnippet", nil];
    NSMutableArray* newSnippetPaths = [NSMutableArray new];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
            [newSnippetPaths addObject:child.path];
        }
    }
    self.snippetsPaths = newSnippetPaths;
    [self loadSnippets];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
	[self loadSnippets];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadMetadataFailedWithError: %@", error);
	if(error.code == 403){
		NSAlert *alert = [[NSAlert alloc]init];
		[alert setMessageText:@"Log in"];
		[alert setInformativeText:@"Is necessary that you login again"];
		[alert runModal];
	}
    self.retrieveSnippetsButton.state = NSOnState;
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath{
	self.retrieveSnippetsButton.state = NSOnState;
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error{
    NSLog(@"restClient:loadFileFailedWithError: %@", error);
	 self.retrieveSnippetsButton.state = NSOnState;
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
	   contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
- (void)displayError {
	NSAlert *alert = [[NSAlert alloc]init];
	[alert setMessageText:@"Error"];
	[alert setInformativeText:@"There was an error loading your snippets."];
	[alert runModal];
}
-(NSString*)snippetsPathDropbox{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:@"1D5E6216-EF26-46D6-BA6B-6ACD7CE0C58B.codesnippet"];
}

#pragma mark save codesnipet  

-(void)saveToDirectory:(NSString*)path
{

    NSString *file = [path stringByReplacingOccurrencesOfString:@"/var/folders/hk/tmjpzj9j0373zls6pnp905z00000gn/T/" withString:@""];

	file = [file stringByReplacingOccurrencesOfString:@"/Snippets/" withString:@""];


	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	NSString *documentsDirectory = [paths objectAtIndex:0];
	documentsDirectory = [documentsDirectory stringByReplacingOccurrencesOfString:@"Documents" withString:@"Library/Developer/Xcode/UserData/CodeSnippets/"];

	NSString *txtPath = [documentsDirectory stringByAppendingPathComponent:file];

	for(id val in self.snippetsPaths){
		NSLog(@" %@", val);
		[self.restClient loadFile:val intoPath:txtPath];
	}
}



-(void)updateLoginButton{
	if ([[DBSession sharedSession] isLinked]) {
        self.loginButton.title = @"Log Out Dropbox";
    } else {
        self.loginButton.title = @"Log In Dropbox";
        self.loginButton.state = [[DBAuthHelperOSX sharedHelper] isLoading] ? NSOffState : NSOnState;
    }
}
-(void)loadSnippets{

	 if ([self.snippetsPaths count] == 0) {

        NSString *msg = nil;
        if ([DBSession sharedSession].root == kDBRootDropbox) {
            msg = @"Put .codesnippet in your Snippets folder to use SSXCodeSnippets";
        } else {
            msg = @"Put .codesnippet in your app's App folder to use SSXCodeSnippets!";
        }

        NSLog(@"Error: %@", msg);

        self.retrieveSnippetsButton.state = NSOnState;
    } else {

		for(id val in self.snippetsPaths){
			_snippetPathSaved = [_snippetPathSaved stringByAppendingString:[NSString stringWithFormat:@"%@ \n\n",val]];
			self.textViewSnippets.string = _snippetPathSaved;
			[self saveToDirectory:val];
		}
    }

}

#pragma  mark service


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
