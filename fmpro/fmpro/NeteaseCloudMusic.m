//
//  NeteaseCloudMusic.m
//  fmpro
//
//  Created by jovi on 14-4-25.
//  Copyright (c) 2014年 jovi. All rights reserved.
//

#import "NeteaseCloudMusic.h"
#import "AFNetworking.h"
#import <CommonCrypto/CommonDigest.h>
#import <math.h>
@interface NeteaseCloudMusic() {
    AFHTTPRequestOperationManager *operationManager;
}
@end

static NeteaseCloudMusic *instance = nil;

@implementation NeteaseCloudMusic

+ (NeteaseCloudMusic *) sharedInstance
{
    static dispatch_once_t disLock = 0;
    
    if (instance == nil) {
        dispatch_once(&disLock, ^{
            if (instance == nil) {
                instance = [[NeteaseCloudMusic alloc] init];
            }
        });
    }
    
    return instance;
}

-(void)getSonyWithTrack:(Track*)track
{
    NSString *url=@"http://music.163.com/api/search/pc";
    operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager.requestSerializer setValue:@"appver=1.5.2" forHTTPHeaderField:@"Cookie"];
    operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSDictionary *parameters = @{@"s": [NSString stringWithFormat:@"%@ %@",track.title,track.artist],@"limit": @"5",@"type": @"1",@"offset": @"0"};
    
    [operationManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id  result = responseObject[@"result"];
        NSArray *songs = result[@"songs"];
        id song = songs[0];
        id hMusic = song[@"hMusic"];
        
        NSInteger len = [hMusic[@"playTime"] integerValue] / 1000;
        
        if ((len - track.length) <= 5.0){
            NSString *dfsId = [NSString stringWithFormat:@"%@",hMusic[@"dfsId"]];;
            NSString *extension = hMusic[@"extension"];
            NSString *encryptPath = [self encode_withkey:dfsId];
            NSString *url = [NSString stringWithFormat:@"http://m2.music.126.net/%@/%@.%@",encryptPath,dfsId,extension];
            track.hlink = url;
        }else{
            track.hlink = nil;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}


- (void)getSonyWithTrack:(Track *)track completionHandler:(NeteaseCloudMusicBlock)urlBlock errorHandler:(NeteaseCloudMusicErrorBlock)errorBlock{
    
    NSString *url=@"http://music.163.com/api/search/pc";
    operationManager = [AFHTTPRequestOperationManager manager];
    [operationManager.requestSerializer setValue:@"appver=1.5.2" forHTTPHeaderField:@"Cookie"];
    operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    
    NSDictionary *parameters = @{@"s": [NSString stringWithFormat:@"%@ %@",track.title,track.artist],@"limit": @"5",@"type": @"1",@"offset": @"0"};
    
    [operationManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id  result = responseObject[@"result"];
        NSArray *songs = result[@"songs"];
        id song = songs[0];
        id hMusic = song[@"hMusic"];
        NSInteger len = [hMusic[@"playTime"] integerValue] / 1000;
        
        if ((len - track.length) <= 5){
            NSString *dfsId = [NSString stringWithFormat:@"%@",hMusic[@"dfsId"]];;
            NSString *extension = hMusic[@"extension"];
            NSString *encryptPath = [self encode_withkey:dfsId];
            NSString *url = [NSString stringWithFormat:@"http://m2.music.126.net/%@/%@.%@",encryptPath,dfsId,extension];
            NSLog(@"url:%@",url);
            urlBlock(url);
        }else{
            urlBlock(nil);

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        errorBlock(error);
    }];
}

-(NSString*)encode_withkey:(NSString*)aString
{
    NSString *keyStr = @"3go8&$8*3*3h0k(2)2";
    NSData *key = [keyStr dataUsingEncoding:NSISOLatin1StringEncoding];
    
    CC_MD5_CTX md5_ctx;
    CC_MD5_Init(&md5_ctx);
    
    CC_MD5_Update(&md5_ctx,
                  [[self simpleKeyXOR:aString
                            withBytes:(Byte*)[key bytes]
                                  len:(CC_LONG)[keyStr length]] bytes],
                  (CC_LONG)[aString length]);
    
    unsigned char result[128];
    
    md5To64(result, &md5_ctx);
    for(size_t i = 0; result[i]; ++i) {
        if (result[i] == '+') result[i]='-';
        if (result[i] == '/') result[i]='_';
    }
    
    NSString *outMd5 = [NSString stringWithCString:(char*)result encoding:NSISOLatin1StringEncoding];
    return outMd5;
    
    
}


void md5To64(unsigned char *output, CC_MD5_CTX *context)
{
    size_t       i;
    u_char       digest[18];
    u_char      *p;
    const u_char basis_64[] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    CC_MD5_Final(digest, context);
    digest[sizeof(digest) - 1] = digest[sizeof(digest) - 2] = 0;
    
    p = output;
    for (i = 0; i < sizeof(digest); i += 3) {
        *p++ = basis_64[digest[i] >> 2];
        *p++ = basis_64[((digest[i] & 0x3) << 4) |
                        ((digest[i + 1] & 0xF0) >> 4)];
        *p++ = basis_64[((digest[i + 1] & 0xF) << 2) |
                        ((digest[i + 2] & 0xC0) >> 6)];
        *p++ = basis_64[digest[i + 2] & 0x3F];
    }
    
    *p-- = '\0';
    *p-- = '=';
    *p-- = '=';
}

-(NSData*)simpleKeyXOR:(NSString*)str withBytes:(Byte*)key len:(int)keyLen
{
    NSMutableData* data = [NSMutableData dataWithData:[str dataUsingEncoding:NSISOLatin1StringEncoding]];
    Byte *allData = (Byte*)[data bytes];
    for(int i=0; i<[data length]; i++)
    {
        allData[i] = allData[i] ^ key[i%keyLen];
    }
    return data;
}
@end
