//
//  myDB.m
//  CustManager
//
//  Created by Stronger Shen on 2014/1/13.
//  Copyright (c) 2014年 MobileIT. All rights reserved.
//

#import "myDB.h"
myDB *sharedInstance;

@implementation myDB

-(void)loadDB
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *dbPath = [documentPath stringByAppendingPathComponent:@"mydatabase.sqlite"];
    
    db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"Could not open database");
        return;
    }

}


-(id)init
{
    self=[super init];
    if (self) {
        [self loadDB];
    }
    
    return self;
}

+ (myDB *)sharedInstance
{
    if (sharedInstance==nil) {
        sharedInstance = [[myDB alloc] init];
    }
    return sharedInstance;
}

- (id)queryCust
{
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *result = [db executeQuery:@"select * from chatHistory order by ID"];
    while ([result next]) {
        NSString *ID                = [result stringForColumn:@"ID"];
        NSString *chat_history      = [result stringForColumn:@"chat_history"];
        NSString *time              = [result stringForColumn:@"time"];
        NSString *from_token_id     = [result stringForColumn:@"from_token_id"];
        NSString *from_fb_id        = [result stringForColumn:@"from_fb_id"];
        NSString *user_nickname     = [result stringForColumn:@"user_nickname"];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              ID,               @"ID",
                              chat_history,     @"chat_history",
                              time,             @"time",
                              from_token_id,    @"from_token_id",
                              from_fb_id,       @"from_fb_id",
                              user_nickname,    @"user_nickname",
                              nil];
        [rows addObject:dict];
    }
   // NSLog(@"rows %@",[rows lastObject]);
    
    return rows;
    
//        while ([result next]) {
//            NSString *cust_no = [result stringForColumn:@"cust_no"];
//            NSString *cust_name = [result stringForColumn:@"cust_name"];
//            NSString *cust_tel = [result stringForColumn:@"cust_tel"];
//            NSString *cust_addr = [result stringForColumn:@"cust_addr"];
//            NSString *cust_email = [result stringForColumn:@"cust_email"];
//            
//            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  cust_no, @"cust_no",
//                                  cust_name, @"cust_name",
//                                  cust_tel, @"cust_tel",
//                                  cust_addr, @"cust_addr",
//                                  cust_email, @"cust_email",
//                                  nil];
//            [rows addObject:dict];
//        }
//        
//        return rows;


}


                            //INSERT INTO  `b16_14177414_bossWarning`.`chatHistory` (`ID` ,`chat_history` ,`time` ,`from_token_id` ,`from_fb_id` ,`user_nickname`)VALUES ('123',  '123',  '',  '123',  '21',  '123');
- (void)insertID:(NSString *)ID chat_history:(NSString *)chat_history time:(NSString *)time from_token_id:(NSString *)from_token_id from_fb_id:(NSString*)from_fb_id user_nickname:(NSString*)user_nickname
{
    //if (![db executeUpdate:@"insert into chatHistory (ID,chat_history,time,from_token_id,from_fb_id,user_nickname) values (?,?,?,?,?,?)", ID,chat_history, time, from_token_id,from_fb_id ,user_nickname ])
    NSString* sql =@"INSERT INTO chatHistory (ID ,chat_history ,time ,from_token_id ,from_fb_id ,user_nickname)VALUES (?,?,?,?,?,?)";
    if (![db executeUpdate:sql,    ID ,chat_history ,time ,from_token_id ,from_fb_id ,user_nickname ])
    {
        NSLog(@"Could not insert data: %@", [db lastErrorMessage]);
    }
    
   // NSLog(@"%@ %@ %@ %@ %@ ",chat_history , time , from_token_id, from_fb_id , user_nickname);
}




-(int)maxChatHistoryID
{
    int maxID;
    
    maxID = [[db executeQuery:@"select max(id) from 'chatHistory'"].query integerValue]  ;

    
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM chatHistory"];
    NSMutableArray* allIDs=[[NSMutableArray alloc]init];
    while ([rs next]) {
        
        NSString *theID = [rs stringForColumn:@"id"];
        [allIDs addObject:theID];
    }
    
    [rs close];
    
    maxID = [[allIDs lastObject] integerValue];
    
    return maxID;
}

@end
