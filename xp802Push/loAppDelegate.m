//
//  loAppDelegate.m
//  xp802Push
//
//  Created by Lova on 2014/1/6.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loAppDelegate.h"
#import "loViewController.h"
#import "loConnectPHP.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "myDB.h"
@implementation loAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self sqliteCheck];
    [FBProfilePictureView class];
    
    [Parse setApplicationId:@"Oi95tWW0SuVoqZqZwRpLqV2VD72FgGcCaWm3oPrb"
                  clientKey:@"pwztiuhmtwK3rm7ER5OIclSEEWWWB3ob4tbnkSpm"];
//for parse
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeAlert)];

    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound |
                                                                           UIRemoteNotificationTypeAlert)];
    
    return YES;
    
}
-(void)sqliteCheck
{
    //可讀寫 db
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"mydatabase.sqlite"];
    
    //發佈安裝時的原始 db
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mydatabase.sqlite"];
    
    //iOS 的檔案管理
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    if (!success) {
        //dbPath 不存在，需要 copy 到 Documents 內
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        if (!success) {
            NSLog(@"Copy Error: %@", [error description]);
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
   
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
 
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}




-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:@"noGroups" // [loConnectPHP shareInstance].plistDict[@"group_id"]
                                  forKey:@"channels"];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    

    
    
    NSString *newToken = [deviceToken description];
    
    newToken =[newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken =[newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.tokenString= [[NSString alloc]initWithString:newToken];
    
    [loConnectPHP shareInstance].plistDict[@"token_id"] =self.tokenString ;
    [[loConnectPHP shareInstance] writePlist];
    
    
    
    //取得user資料欄 存在loConnectPHP.userDictionary   若查無token 則insert  以非同步方式進行
    [[loConnectPHP shareInstance] loSQLCommand:[NSString stringWithFormat:@"SELECT * FROM  users where token_id='%@'",_tokenString]
                                     afterSYNC:loAfterASYNC_DO_RefreshUserDictionary
                                    Completion:^{
                                        
                                         if ([[loConnectPHP shareInstance].userDictionary[@"token_id"] isEqual: _tokenString] ) { NSLog(@"db has token_id");
        
                                         }else { // sign up and refresh again
                                             

                                             
            [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"insert into users (token_id) values ('%@')",_tokenString]
                                            afterSYNC:loAfterASYNC_DO_sign_up_user
                                           Completion:^{
                                                               
                    [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"SELECT * FROM  users where token_id='%@'",_tokenString]
                                                    afterSYNC:loAfterASYNC_DO_RefreshUserDictionary
                                                   Completion:^{}];
            }];
                                         }
                                        
                                        
                                        //////////////////                          SELECT * FROM `2` where ID > 0
                                        //撈聊天記錄    查詢mysql上 id 比  sqlite記錄中 id大的  (未讀)  有的話就在loAfterASYNC_DO_reciveMessage中順便儲存
                                        
                                        NSString* groupID =[loConnectPHP shareInstance].plistDict[@"group_id"];
                                        
                                        if ( ![groupID isEqualToString:@"0"]) {
                                        
                            
                                            //SELECT max(id) FROM `2`
                                            [[loConnectPHP shareInstance]loSQLCommandWithStringReturn:[NSString stringWithFormat:@"SELECT max(id) FROM `%@`",groupID]//遠端  history maxID
                                                                                              withKey:@"max(id)"
                                                                                           Completion:^(NSString *thekey) {
                                                                                               
                                                                                               NSString* historyID=[NSString stringWithFormat:@"%d",[[myDB sharedInstance]maxChatHistoryID]];  //近端 history max id
                                                                                               
                                                                                               NSLog(@"thekey :%@ historyID:%@",thekey,historyID);
                                                                                               
                                                                                               
                                                                                               if ( thekey == (id)[NSNull null] || [thekey isEqualToString:historyID ]) {
                                                                                                   //遠端沒記錄  或  兩者一樣   則無需同步
                                                                                               } else {
                                                                                                   //要求下載 遠端上較新的內容   以loAfterASYNC_DO_reciveMessage 存到sqlite
                                                                                                   [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"SELECT * FROM `%@` where ID > %@",groupID,historyID ]
                                                                                                                                   afterSYNC:loAfterASYNC_DO_reciveMessage
                                                                                                                                  Completion:^{
                                                                                                                                      
                                                                                                                                  }];}
                                            }];
                                            
                                        }
                                    }];
 
    
    NSLog(@"%@",[loConnectPHP shareInstance].plistDict);
    

    
    [[loConnectPHP shareInstance]loSQLCommandWithStringReturn:[NSString stringWithFormat:@"SELECT warned_fb_id FROM `all_groups` where group_id = '%@'",
                                                               [loConnectPHP shareInstance].plistDict[@"group_id"]]
                                                      withKey:@"warned_fb_id"
                                                   Completion:^(NSString *thekey) {
                                                       if ([thekey isEqualToString:@""]) {
                                                           
                                                       }else{
                                                           [[NSNotificationCenter defaultCenter]postNotificationName:@"gotBossWarning" object:nil];
                                                       }
    }];
}


-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"failed to get device token:\n %@  \n\n",error);
    [myDB sharedInstance];

}


/*fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler*/
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"recive the notification :%@" , userInfo[@"aps"][@"alert"]);


    
    //SELECT max(id) FROM `2`
     NSString* groupID =[loConnectPHP shareInstance].plistDict[@"group_id"];
    
    [[loConnectPHP shareInstance]loSQLCommandWithStringReturn:[NSString stringWithFormat:@"SELECT max(id) FROM `%@`",groupID]//遠端  history maxID
                                                      withKey:@"max(id)"
                                                   Completion:^(NSString *thekey) {
                                                       
                                                       NSString* historyID=[NSString stringWithFormat:@"%d",[[myDB sharedInstance]maxChatHistoryID]];  //近端 history max id
                                                       
                                                       NSLog(@"thekey :%@ historyID:%@",thekey,historyID);
                                                       
                                                       
                                                       if ( thekey == (id)[NSNull null] || [thekey isEqualToString:historyID ]) {
                                                           //遠端沒記錄  或  兩者一樣   則無需同步
                                                       } else {
                                                           //要求下載 遠端上較新的內容   以loAfterASYNC_DO_reciveMessage 存到sqlite
                                                           [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"SELECT * FROM `%@` where ID > %@",groupID,historyID ]
                                                                                           afterSYNC:loAfterASYNC_DO_reciveMessage
                                                                                          Completion:^{
                                                                                              
                                                                                          }];}
                                                   }];
    
    
    
    if (application.applicationState == UIApplicationStateActive) {
        //app active時不震動不發聲
    }else{
        //進入app時
        //震動
        if ([[loConnectPHP shareInstance].plistDict[@"vibrate"] isEqualToString:@"Yes"]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        //音效
        if ([[loConnectPHP shareInstance].plistDict[@"sound"] isEqualToString:@"Yes"]) {
            NSURL *soundURL=[[NSBundle mainBundle] URLForResource:@"dive" withExtension:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(soundURL), &soundFileObject);
            
            AudioServicesPlaySystemSound(soundFileObject);
        }
    }
    //跳出view
    //[PFPush handlePush:userInfo];
    
    if ([userInfo[@"aps"][@"alert"] isEqualToString:@"BOSS WARNING!   "]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"gotBossWarning" object:nil];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    }else if([userInfo[@"aps"][@"alert"] isEqualToString:@"Safe!!!  (´▽｀)   "]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"warningCheck" object:nil];
    }
    
    
    
}


#pragma mark - for fb
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL wasHandled=[FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    return wasHandled;
}

@end
