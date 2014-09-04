//
//  loMySQLFramework.m
//  xp802Push
//
//  Created by Lova on 2014/1/23.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loConnectPHP.h"
#import "myDB.h"
NSString *plistParh;

loConnectPHP* entity;

@implementation loConnectPHP




-(void)loadPlist
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    
    plistParh = [documentPath stringByAppendingPathComponent:@"userData.plist"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:plistParh];
    
    if (!success) {
        //dbPath 不存在，需要 copy 到 Documents 內
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"userData.plist"];
        NSError *error;

        success = [fileManager copyItemAtPath:defaultDBPath toPath:plistParh error:&error];
        
        if (!success) {
            NSLog(@"Copy Error: %@", [error description]);
        }
    }
    
    _plistDict=[NSMutableDictionary dictionaryWithContentsOfFile:plistParh];
    
}

-(void)writePlist
{
    [_plistDict writeToFile:[NSString stringWithFormat:@"%@",plistParh]
                 atomically:YES];
}

-(id)init
{
    self=[super init];
    
    if (self) {
        [self loadPlist];
    }
    return self;
}

+(loConnectPHP*)shareInstance
{
    if (entity==nil) {
        entity=[[loConnectPHP alloc]init];
        
    }
    
    return entity;
}


-(NSArray*)loSQLCommand:(NSString*)sqlCommand afterSYNC:(NSInteger)loAfterSYNC Completion:(void (^)(void))completion
{
    if (_userDictionary == nil) {
        _userDictionary=[[NSMutableDictionary alloc]init];
    }
    
    
    
  // NSLog(@"\ntheCommand is :%@",sqlCommand);
    
    NSString *theCommand=[NSString stringWithFormat:@"sqlCommand=%@",sqlCommand];

    NSURL *url = [[NSURL alloc] initWithString:kHost];
    
    NSMutableString *httpBodyString=[[NSMutableString alloc] initWithString:theCommand];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue* queue=[[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               if (data.length>0 && connectionError==nil) {
                                   NSArray* array=[NSJSONSerialization JSONObjectWithData:data
                                                                                  options:NSJSONReadingAllowFragments
                                                                                    error:nil];
                                  // NSLog(@" switch : %d",loAfterSYNC);
                                   
                                       switch (loAfterSYNC) {
                                           case 0:
                                               [self refreshUserDictionary:array];
                                               break;
                                           case 1:
                                               [self signUpUser:array];
                                               break;
                                           case 2:
                                               [self updateUserNickname];
                                               break;
                                           case 3:
                                               [self updateGroupID:array];
                                               break;
                                           case 4:
                                               [self updateUserPhotoLink];
                                               break;
                                           case 5:
                                               [self sendMessage];
                                               break;
                                           case 6:
                                               [self reciveMessage:array];
                                               break;
                                           case 7:
                                               [self getUsersFB:array];
                                               break;
                                           case 8:
                                               [self getUsersLocation:array];
                                               break;
                                           default:
                                               break;
                                       }
                                   
                                   completion();
                                   
                                   return ;
                               } else if(data.length==0 && connectionError==nil){
                                   completion();
                               } else if(connectionError!=nil){
                                   [[NSNotificationCenter defaultCenter]postNotificationName:@"showAlert" object:connectionError];
                               }
                               
                               
                           }];

    return [NSArray array];
}


-(NSString*)loSQLCommandWithStringReturn:(NSString*)sqlCommand withKey:(NSString*)key
{

//    NSLog(@"\nloSQLCommandWithStringReturn : theCommand is :%@",sqlCommand);
    
    NSString *theCommand=[NSString stringWithFormat:@"sqlCommand=%@",sqlCommand];
    
    //宣告一個 NSMutableURLRequest 並給予一個記憶體空間
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //宣告一個 NSURL 並給予記憶體空間、連線位置(放於本機localhost，檔案名稱為iphone.php)
    NSURL *connection = [[NSURL alloc] initWithString:kHost];
    
    //宣告一個 NSMutableString 並給予記憶體位置，將內容設定為上面的string
    NSMutableString *httpBodyString=[[NSMutableString alloc] initWithString:theCommand];
    //設定連線位置
    [request setURL:connection];
    //設定連線方式
    [request setHTTPMethod:@"POST"];
    //將編碼改為UTF8
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    //轉換為NSData傳送
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSError* error;
    
    
    
    
    NSArray* array=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSDictionary* dict= array[0];
    

    if (error!=nil) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"showAlert" object:error];
    }
    
    
    return dict[key];
}



//completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError)) handler NS_AVAILABLE(10_7, 5_0);

-(BOOL)loSQLCommandWithStringReturn:(NSString*)sqlCommand withKey:(NSString*)key Completion:(void (^)(NSString* thekey))completion
{
    
    
//    NSString *theCommand=[NSString stringWithFormat:@"sqlCommand=%@",sqlCommand];
//    
//    //宣告一個 NSMutableURLRequest 並給予一個記憶體空間
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//    //宣告一個 NSURL 並給予記憶體空間、連線位置(放於本機localhost，檔案名稱為iphone.php)
//    NSURL *connection = [[NSURL alloc] initWithString:kHost];
//    
//    //宣告一個 NSMutableString 並給予記憶體位置，將內容設定為上面的string
//    NSMutableString *httpBodyString=[[NSMutableString alloc] initWithString:theCommand];
//    //設定連線位置
//    [request setURL:connection];
//    //設定連線方式
//    [request setHTTPMethod:@"POST"];
//    //將編碼改為UTF8
//    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
//    //轉換為NSData傳送
//    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    
//    NSError* error;
//    
//    NSArray* array=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
//
//    if (error!=nil) {
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"showAlert" object:error];
//    }
    
    ///////////////////////////////////////////
    
    NSString *theCommand=[NSString stringWithFormat:@"sqlCommand=%@",sqlCommand];
    
    NSURL *url = [[NSURL alloc] initWithString:kHost];
    
    NSMutableString *httpBodyString=[[NSMutableString alloc] initWithString:theCommand];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[httpBodyString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue* queue=[[NSOperationQueue alloc]init];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               NSDictionary* dict;

                               if (data.length>0 && connectionError==nil) {
                                   
                                   NSArray* array=[NSJSONSerialization JSONObjectWithData:data
                                                                                  options:NSJSONReadingAllowFragments
                                                                                    error:nil];
                                   // NSLog(@" switch : %d",loAfterSYNC);
                                   dict= array[0];

                   
                                   
                                   completion(dict[key]);
                                   
                                   return ;
                               } else if(data.length==0 && connectionError==nil){
                                   completion(dict[key]);
                               } else if(connectionError!=nil){
                                   [[NSNotificationCenter defaultCenter]postNotificationName:@"showAlert" object:connectionError];
                               }
                               
                               
                           }];
///////////////////////////////////////////////////////////////
//    NSLog(@"array = %@",array);
//    NSLog(@"thekey id = %@",key);
    return YES;
}

-(void)refreshUserDictionary:(NSArray*)array
{
   // NSLog(@"dict dd %@",array);

    
    _userDictionary = array[0];
    [_plistDict setObject:array[0][@"user_nickname"] forKey:@"user_nickname"] ;
    [_plistDict setObject:array[0][@"group_id"] forKey:@"group_id"] ;

    [self writePlist];
    
    _isUserDictionaryReady=YES;
}

-(void)signUpUser:(NSArray*)array
{
  //  NSLog(@"signUpUser : %@",array);
}

-(void)updateUserNickname
{
    
}

-(void)updateGroupID:(NSArray*)array
{
   // NSLog(@" max group_ID :%@",array[0][@"max(group_id)"]);
    
    
}

-(void)updateUserPhotoLink
{
    
}

-(void)sendMessage
{
 //送推播    array( token,token,token,.....)
    
//    NSURL *url = [NSURL URLWithString:@"http://www.site.com/sendData.php"];
//    
//    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url
//                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData
//                                                          timeoutInterval:60];
//    
//    [theRequest setHTTPMethod:@"POST"];
//    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    
//    NSString *postData = [NSString stringWithFormat:@"name1=%@&name2=%@", data1, data2];
//    
//    NSString *length = [NSString stringWithFormat:@"%d", [postData length]];
//    [theRequest setValue:length forHTTPHeaderField:@"Content-Length"];
//    
//    [theRequest setHTTPBody:[postData dataUsingEncoding:NSASCIIStringEncoding]];
//    
//    NSURLConnection *sConnection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
//    [sConnection start];
    
    ////////
    //history 存mysql
    
    
    ////////////
}

//receive from host
-(void)reciveMessage:array
{
    
    if(_chatHistoryDictionary==nil)
        _chatHistoryDictionary=[[NSMutableArray alloc]init];
    
    _chatHistoryDictionary=array;
    
    for (NSDictionary* dict in array) {
        [[myDB sharedInstance]insertID:dict[@"ID"]
                          chat_history:dict[@"chat_history"]
                                  time:dict[@"time"]
                         from_token_id:dict[@"from_token_id"]
                            from_fb_id:dict[@"from_fb_id"]
                         user_nickname:dict[@"user_nickname"]];

   //     NSLog(@"dict =  %@",dict);
    }
     // NSLog(@"%@",  [[myDB sharedInstance]queryCust]);
#pragma mark -  need to reload data     chat table view
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadLoTableViewChat" object:nil];
    
    
}

-(void)reciveMessageIfNecessary
{
    
}
-(NSArray*)getUsersFB:array
{
    _fbIDArray =nil;
    if (_fbIDArray ==nil) {
        _fbIDArray=[[NSMutableArray alloc]init];
    }
    
    for (NSDictionary* dict in array) {
        [_fbIDArray addObject:dict[@"FB_ID"]];
    }
    
    return _fbIDArray;
}
-(NSArray*)getUsersLocation:array
{
    _UsersLocation =nil;
    if (_UsersLocation ==nil) {
        _UsersLocation=[[NSMutableArray alloc]init];
    }
    
    for (NSDictionary* dict in array) {
        [_UsersLocation addObject:dict];
    }
    
    return _UsersLocation;
}
@end
