//
//  loSetupTableViewController.m
//  xp802Push
//
//  Created by Lova on 2014/2/4.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loSetupTableViewController.h"
#import "loViewController.h"
#import "loConnectPHP.h"
#import "loAppDelegate.h"
#import <Parse/Parse.h>
@interface loSetupTableViewController ()
{
    bool            isLoUserNicknameChanged;
    UIImageView*    loLoginViewCoverImage;
}
@end

@implementation loSetupTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isLoUserNicknameChanged = NO;
    [self.loUserNickname setText:[loConnectPHP shareInstance].plistDict[@"user_nickname"]];
    
    
    [self.loUserNickname addTarget:self action:@selector(loUserNicknameChanged) forControlEvents:UIControlEventEditingChanged];
    
    [self.loLabelGroupState setText:[loConnectPHP shareInstance].plistDict[@"group_id"]];

    
   
    [_loSwitcherVibrate setOn: [[loConnectPHP shareInstance].plistDict[@"vibrate"   ] isEqualToString:@"Yes"]  ? YES :NO ];
    [_loSwitcherSound   setOn: [[loConnectPHP shareInstance].plistDict[@"sound"     ] isEqualToString:@"Yes"]  ? YES :NO ];
    [_loSwitcherBubble  setOn: [[loConnectPHP shareInstance].plistDict[@"bubble"    ] isEqualToString:@"Yes"]  ? YES :NO ];


    _loSetupFBprofilePhotoView.profileID= [loConnectPHP shareInstance].plistDict[@"fb_id"];
    _loSetupFBprofilePhotoView.layer.cornerRadius=_loSetupFBprofilePhotoView.frame.size.height/2;
    
    
    
    NSString* title= [[ loConnectPHP shareInstance].plistDict[@"group_id"] isEqualToString:@"0"] ? @"Join" : @"Leave" ;
    [_loBtnJoin setTitle:title forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - button
- (IBAction)loBtnJoin:(UIButton *)sender {
    
    
    
    
    if ( [[loConnectPHP shareInstance].plistDict[@"group_id"] isEqualToString:@"0" ] ) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Join a group"
                                                        message:@"\n\n"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Save", nil];
        
        alert.alertViewStyle=UIAlertViewStylePlainTextInput;
        UITextField* tf = [alert textFieldAtIndex:0];
        tf.keyboardType=UIKeyboardTypeNumberPad;
        
        [alert show];
        
    }else{
        
        
        UIActionSheet* actionSheet=[[UIActionSheet alloc]initWithTitle:@"Leave the Gourp?"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                destructiveButtonTitle:@"Leave"
                                                     otherButtonTitles: nil];
        [actionSheet showInView:self.view];
        
        return;
    }
    
}

- (IBAction)loBtnCreateGroup:(UIButton *)sender {
    

    if (  [[loConnectPHP shareInstance].plistDict[@"group_id"] isEqualToString:@"0"]) {
        
    }else{
        //若已有group
        return;
    }
    
    int groupID;
    groupID= [[[loConnectPHP shareInstance]loSQLCommandWithStringReturn:@"SELECT MAX( group_id ) FROM  `all_groups`"
                                                               withKey:@"MAX( group_id )"] intValue];
    
    groupID++;
    
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setObject:@[   [NSString stringWithFormat:@"a%d",groupID]   ]
                     forKey:@"channels"];
    [installation saveInBackground];
    
    
    
    
    
    
    [loConnectPHP shareInstance].plistDict[@"group_id"] =[NSString stringWithFormat:@"%d",groupID ];
    [[loConnectPHP shareInstance] writePlist];
    
    [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"update users set group_id='%d' where token_id='%@'",groupID,[loConnectPHP shareInstance].plistDict[@"token_id"]]
                                    afterSYNC:-1
                                   Completion:^{

                                       
                                       /*
                                        CREATE TABLE  `b16_14177414_bossWarning`.`3` (`ID` INT( 10 ) NOT NULL ,`chat_history` VARCHAR( 256 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,`time` VARCHAR( 32 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,`from_token_id` VARCHAR( 64 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,`from_fb_id` INT( 20 ) NOT NULL ,`user_nickname` VARCHAR( 32 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,UNIQUE (`ID`)) ENGINE = MYISAM
                                        
                                        
                                       */
                                       
                                       
                                       
            [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"CREATE TABLE  `b16_14177414_bossWarning`.`%@` (`ID` INT( 10 ) NOT NULL ,`chat_history` VARCHAR( 256 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,`time` VARCHAR( 32 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,`from_token_id` VARCHAR( 64 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,`from_fb_id` VARCHAR( 20 ) NOT NULL ,`user_nickname` VARCHAR( 32 ) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL ,UNIQUE (`ID`)) ENGINE = MYISAM" ,[loConnectPHP shareInstance].plistDict[@"group_id"]]
                                            afterSYNC:-1
                                           Completion:^{
                                               
                    [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"INSERT INTO `b16_14177414_bossWarning`.`all_groups` (`group_id`, `group_owner`) VALUES ('%d', '%@');",groupID,[loConnectPHP shareInstance].plistDict[@"token_id"]]
                                                    afterSYNC:-1
                                                   Completion:^{
                                                       
                                                       
                                                
                                                       
                                                       
                                        
                                                       
                                                   }];
                                           }];
                                   
                                   
                                   }];
    

//    NSArray* channels=[NSArray arrayWithObject:@"0" ];
//    
//    PFInstallation* currentInstallation=[PFInstallation currentInstallation];
//    [currentInstallation setObject:@"lova"
//                            forKey:@"objectId"];
//    [currentInstallation saveInBackground];

}



- (IBAction)loBtnInviteFriends:(UIButton *)sender {
    
    
//塗鴉牆
//    [FBWebDialogs presentFeedDialogModallyWithSession:nil
//                                           parameters:params
//                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
//        
//    }];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization
                        dataWithJSONObject:@{
                                             @"social_karma": @"5",
                                             @"badge_of_awesomeness": @"1"}
                        options:0
                        error:&error];
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
        return;
    }
    
    NSString *giftStr = [[NSString alloc]
                         initWithData:jsonData
                         encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* params = [@{@"data" : giftStr} mutableCopy];
    
    // Display the requests dialog
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Learn how to make your iOS apps social."
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                 }
             }
         }
     }];
}
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
- (IBAction)loBtnSetupDone:(UIBarButtonItem *)sender {
    
    if (isLoUserNicknameChanged) {
        [loConnectPHP shareInstance].plistDict[@"user_nickname"] = self.loUserNickname.text;
        [[loConnectPHP shareInstance] writePlist];
    
    [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"update users set user_nickname='%@' where token_id='%@'",
                                               [loConnectPHP shareInstance].plistDict[@"user_nickname"] ,
                                               [loConnectPHP shareInstance].plistDict[@"token_id"]     ]
    
                                    afterSYNC:-1
                                   Completion:^{}];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:^{}];

}

- (IBAction)loSwitcherChanged:(UISwitch *)sender {
    
    [loConnectPHP shareInstance].plistDict[@"sound"]    = [_loSwitcherSound     isOn  ] ? @"Yes" : @"No" ;
    [loConnectPHP shareInstance].plistDict[@"vibrate"]  = [_loSwitcherVibrate   isOn  ] ? @"Yes" : @"No" ;
    [loConnectPHP shareInstance].plistDict[@"bubble"]   = [_loSwitcherBubble    isOn  ] ? @"Yes" : @"No" ;

    [[loConnectPHP shareInstance] writePlist];
    
//    NSLog(@"%@ %@ %@",  [loConnectPHP shareInstance].plistDict[@"bubble"],
//                        [loConnectPHP shareInstance].plistDict[@"vibrate"],
//                        [loConnectPHP shareInstance].plistDict[@"sound"]
//          );
}



-(void)loUserNicknameChanged
{
    isLoUserNicknameChanged=YES;
}


#pragma mark - alertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0)
        return;

    if (buttonIndex==1){
        UITextField* alertViewTextField  = [alertView textFieldAtIndex:0];
        NSString* text=[NSString stringWithFormat:@"%@",alertViewTextField.text ];
        NSLog(@" text %@",text);
        [[loConnectPHP shareInstance]loSQLCommandWithStringReturn:[NSString stringWithFormat:@"SELECT group_id FROM `all_groups` where group_id = '%@'",text]
                                                          withKey:@"group_id"
                                                       Completion:^(NSString *thekey) {
                                                           
                                                           NSLog(@"thekey %@",thekey);
                                                           
                                                           if ( thekey ==nil ) {
                                                               
                                                               UIAlertView* alert=[[UIAlertView alloc]initWithTitle:nil
                                                                                                            message:@"there is no such group "
                                                                                                           delegate:self
                                                                                                  cancelButtonTitle:nil
                                                                                                  otherButtonTitles:@"OK", nil];
                                                               [alert show];
                                                           }else{
                                                               
                                                           [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"UPDATE  `b16_14177414_bossWarning`.`users` SET  `group_id` =  '%@' WHERE  `users`.`token_id` =  '%@'",
                                                                                                      text,
                                                                                                      [loConnectPHP shareInstance].plistDict[@"token_id"]]
                                                                                           afterSYNC:-1
                                                                                          Completion:^{
                                                                                              
                                                                                              [loConnectPHP shareInstance].plistDict[@"group_id"]=text;
                                                                                              [[loConnectPHP shareInstance] writePlist];
                                                                                              
                                                                                              
                                                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                  _loLabelGroupState.text=text;
                                                                                              });
                                                                                          }];
                                                           }
        }];
        

    }
    
    

}

#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    NSLog(@"%d",buttonIndex);
    
    UIAlertView* alert;
    
    
    switch (buttonIndex) {
        case 1:
            break;
        case 0:
            [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"UPDATE  `b16_14177414_bossWarning`.`users` SET  `group_id` =  '0' WHERE  `users`.`token_id` =  '%@'",
                                                       [loConnectPHP shareInstance].plistDict[@"token_id"] ]
                                            afterSYNC:-1
                                           Completion:^{
                                               [loConnectPHP shareInstance].plistDict[@"group_id"] =@"0";
                                               [[loConnectPHP shareInstance] writePlist];
                                               
                                           }];

            [_loLabelGroupState setText:@"0"];
            [self.loBtnJoin setTitle:@"Join" forState:UIControlStateNormal];
            break;
        default:
            alert=[[UIAlertView alloc]initWithTitle:nil
                                            message:@"Leave Group Fail!"
                                           delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"ok",nil];
            
            [alert show];
            break;
    }
}


-(void)showAlert:(NSString*)message
{
    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:nil
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:nil
                                       otherButtonTitles:@"ok",nil];
    
    [alert show];
}
@end
