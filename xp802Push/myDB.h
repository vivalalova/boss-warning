//
//  myDB.h
//  CustManager
//
//  Created by Stronger Shen on 2014/1/13.
//  Copyright (c) 2014年 MobileIT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface myDB : NSObject
{
    FMDatabase *db;
}

+ (myDB *)sharedInstance;

- (id)queryCust;

- (void)insertID:(NSString *)ID chat_history:(NSString *)chat_history time:(NSString *)time from_token_id:(NSString *)from_token_id from_fb_id:(NSString*)from_fb_id user_nickname:(NSString*)user_nickname;




-(int)maxChatHistoryID;

@end
