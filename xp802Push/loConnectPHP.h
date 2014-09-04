//
//  loMySQLFramework.h
//  xp802Push
//
//  Created by Lova on 2014/1/23.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface loConnectPHP : NSObject
{
    NSMutableDictionary* usersDict;

}


@property (strong,nonatomic)NSString * token_id;


@property (strong,nonatomic)NSMutableDictionary*    plistDict;
@property (strong,nonatomic)NSMutableDictionary*    userDictionary;  //current user data
@property (strong,nonatomic)NSMutableArray*         fbIDArray;
@property (strong,nonatomic)NSMutableArray*         UsersLocation;
@property (strong,nonatomic)NSMutableArray*         usersPoint;
@property (strong,nonatomic)NSMutableArray*         usersDirection;

@property BOOL isUserDictionaryReady;



@property (strong,nonatomic)NSMutableArray* chatHistoryDictionary;  //chat history

@property (strong,nonatomic)NSMutableArray* arrayData;





+(loConnectPHP*)shareInstance;
-(void)writePlist;

-(NSArray*)loSQLCommand:(NSString*)sqlCommand
          afterSYNC:(NSInteger)loAfterSYNC
         Completion:(void (^)(void))completion;

-(NSString*)loSQLCommandWithStringReturn:(NSString*)sqlCommand
                                 withKey:(NSString*)key;


-(BOOL)loSQLCommandWithStringReturn:(NSString*)sqlCommand
                            withKey:(NSString*)key
                         Completion:(void (^)(NSString* thekey))completion;


typedef NS_ENUM(NSInteger, loAfterASYNC){
    
    loAfterASYNC_DO_RefreshUserDictionary=0,
    loAfterASYNC_DO_sign_up_user=1,
    loAfterASYNC_DO_UpdateUser_nickname=2,
    loAfterASYNC_DO_UpdateGourp_id=3,
    loAfterASYNC_DO_UpdateUser_photo_link=4,
    loAfterASYNC_DO_sendMessage=5,
    loAfterASYNC_DO_reciveMessage=6,
    loAfterASYNC_DO_getUsersFB=7,
    loAfterASYNC_DO_getUsersLocation=8
};


@end
