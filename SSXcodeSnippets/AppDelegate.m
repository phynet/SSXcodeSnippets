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
@property (nonatomic, retain) NSString *currentSnippetsPath;
@property (nonatomic, retain) NSString *snippetHash;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize loginButton = _loginButton;
@synthesize snippetsPaths;
@synthesize currentSnippetsPath;
@synthesize textViewSnippets;
@synthesize requestToken;
@synthesize retrieveSnippetsButton;
@synthesize snippetHash;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self doLogin];
}

-(void)doLogin{

	NSString *appKey = APP_KEY;
    NSString *appSecret = APP_SECRET;
    NSString *root = kDBRootDropbox;

    DBSession *session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    [DBSession setSharedSession:session];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authHelperStateChangedNotification:) name:DBAuthHelperOSXStateChangedNotification object:[DBAuthHelperOSX sharedHelper]];

    [self updateLoginButton];

    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:)
		  forEventClass:kInternetEventClass andEventID:kAEGetURL];

    if ([[DBSession sharedSession] isLinked]) {
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
    self.retrieveSnippetsButton.state = NSOnState;
}

-(void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath{
	self.retrieveSnippetsButton.state = NSOnState;
    self.textViewSnippets.string =  destPath;
	[self saveToDirectory:destPath];
}

-(void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error{
    NSLog(@"restClient:loadFileFailedWithError: %@", error);
	 self.retrieveSnippetsButton.state = NSOnState;
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
	   contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
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
        NSString * snippetPath;

//		if ([self.snippetsPaths count] == 1) {
//            snippetPath = [self.snippetsPaths objectAtIndex:0];
//            if ([snippetPath isEqual:self.currentSnippetsPath]) {
//                NSLog(@"You only have one file to display.");
//
//                return;
//            }
//        } else {
//            // Find a random photo that is not the current photo
//            do {
//                srandom((int)time(NULL));
//                NSInteger index =  random() % [self.snippetsPaths count];
//                snippetPath = [self.snippetsPaths objectAtIndex:index];
//            } while ([snippetPath isEqual:self.currentSnippetsPath]);
//        }


		for(id val in self.snippetsPaths){
			snippetPath = val;
			self.currentSnippetsPath = val;
			[self.restClient loadFile:self.currentSnippetsPath intoPath:[self snippetsPathDropbox]];
		}



    }

}
- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
- (void)displayError {
    NSLog(@"There was an error loading your snippets.");
}
-(NSString*)snippetsPathDropbox{
	return [NSTemporaryDirectory() stringByAppendingPathComponent:@"1D5E6216-EF26-46D6-BA6B-6ACD7CE0C58B.codesnippet"];
}

#pragma mark private methods

- (void)authHelperStateChangedNotification:(NSNotification *)notification {
    [self updateLoginButton];
    if ([[DBSession sharedSession] isLinked]) {
        // You can now start using the API!
        [self didPressRetrieveSnippets:nil];
    }
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    // This gets called when the user clicks Show "App name". You don't need to do anything for Dropbox here
}

@end
