//
//  ServiceDropBox.h
//  SSXcodeSnippets
//
//  Created by sofiaswidarowicz on 23/04/14.
//  Copyright (c) 2014 Media Net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxOSX/DropboxOSX.h>
#import <stdlib.h>
#import <time.h>
#import "ServiceProtocol.h"

@interface ServiceDropBox : NSObject <ServiceProtocol, DBRestClientDelegate>


@end
