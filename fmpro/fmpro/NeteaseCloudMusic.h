//
//  NeteaseCloudMusic.h
//  fmpro
//
//  Created by jovi on 14-4-25.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Track.h"


@interface NeteaseCloudMusic : NSObject
typedef void (^NeteaseCloudMusicBlock)(NSString* hurl);
typedef void (^NeteaseCloudMusicErrorBlock)(NSError* error);


-(void)getSonyWithTrack:(Track*)track;
-(void)getSonyWithTrack:(Track*)track completionHandler:(NeteaseCloudMusicBlock) urlBlock errorHandler:(NeteaseCloudMusicErrorBlock) errorBlock;

+ (NeteaseCloudMusic *) sharedInstance;
@end
