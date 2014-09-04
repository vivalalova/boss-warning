//
//  loViewController.m
//  xp802Push
//
//  Created by Lova on 2014/1/6.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loViewController.h"
#import "loAppDelegate.h"
#import "loChatTableViewCell.h"
#import "loConnectPHP.h"
#import "myDB.h"
#import <Parse/Parse.h>
#import "loWarningOthersView.h"
#import "loLocation.h"
#import "loRadarView.h"
#import <SystemConfiguration/SystemConfiguration.h>


@interface loViewController ()
{
    NSMutableArray * tempDict;
    NSString *tokenID;
    
    NSTimer * timer;
    
    UIImageView *loLoginViewCoverImage;
    NSString* FB_ID;
    loRadarView* radar;
    
    UIButton* btnForHeaderView;
    
    int numberOfShowMessages;
    
    NSTimer* blink;
    
    NSMutableDictionary* dictForProfilePictures;
}

@property (strong,nonatomic)loAppDelegate *AppDelegate;
@property (strong,nonatomic)NSArray       *chatCells;

@end

@implementation loViewController




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //鍵盤事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loKBWillDisappear:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loKBWillAppear:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
    
    //for tableview reload
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadLoTableViewChat)
                                                 name:@"reloadLoTableViewChat" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setAnnos)
                                                 name:@"setAnnos" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAlert:)
                                                 name:@"showAlert" object:nil];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeImageOfLOViewController)
                                                 name:@"changeImageOfLOViewController" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shut) name:@"shut" object:nil];
    
    //設hide有問題
    [self.loSubViewMisc setAlpha:0];
    [self.loFakePopOver setAlpha:0];
    
    //單擊 cell觸發事件
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self
                                                                       action:@selector(didTapOnTableView:)];
    [self.loTableViewChat addGestureRecognizer:tap];
    
    UITapGestureRecognizer* tapFakePopOver= [[ UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnFakePopover:)];
    [self.loFakePopOver addGestureRecognizer:tapFakePopOver];
    
    
    UITapGestureRecognizer* tapSignUpView= [[ UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapOnSignUpView:)];
    [self.loSignUpView addGestureRecognizer:tapSignUpView];
    

    
    
    timer=[NSTimer scheduledTimerWithTimeInterval:3.0
                                            target:self
                                            selector:@selector(TimerCheck)
                                            userInfo:nil
                                            repeats:YES];
    
    //sign in
    [self FBloginview];
    [self.loSignUpSubView addSubview:_loLoginView];
    self.loProfilePictureView.layer.cornerRadius=self.loProfilePictureView.frame.size.height/2;
    self.loImageViewSignUpUserPic.layer.cornerRadius=self.loImageViewSignUpUserPic.frame.size.height/2;

    //misc
    self.loViewMiscBottom.layer.cornerRadius = self.loViewMiscBottom.frame.size.height/2;
    self.loViewMiscFBProfilePictureView.layer.cornerRadius = self.loViewMiscFBProfilePictureView.frame.size.height/2;

    [self.loTextFieldUserNicknameSignUp setText:[loConnectPHP shareInstance].plistDict[@"user_nickname"]];
    
    
    self.loTableViewChat.separatorColor=[UIColor clearColor];
    self.loTableViewChat.scrollsToTop=NO;

    [self reloadLoTableViewChat];
    [self loTableViewScrollToBottom];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    _loViewBlinkWhenWarned.layer.cornerRadius=_loViewBlinkWhenWarned.frame.size.height/2;
    [_loViewBlinkWhenWarned setAlpha:0];
#pragma mark - for radar

    
    if (radar==nil) {
        radar=[[loRadarView alloc]init];
    }

    [self.view addSubview:radar.warningBar];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(radarHeading:)
//                                                 name:@"radarHeading" object:nil];
    
    if ( ![self isConnectionAvailable] ) {
        [self showAlert:@"Connection is not Available"];
    }
    
    
    
    numberOfShowMessages=20;
    
    
    
    
    
    
    UIView* headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    _loTableViewChat.tableHeaderView=headerView;

    btnForHeaderView=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [btnForHeaderView setTitle:@"touch to show more" forState:UIControlStateNormal];
    [btnForHeaderView setTitleColor:[UIColor colorWithRed:0.5 green:0.5 blue:1 alpha:1] forState:UIControlStateNormal];
    [btnForHeaderView addTarget:self action:@selector(headerTouched) forControlEvents:UIControlEventTouchUpInside];
    [_loTableViewChat addSubview:btnForHeaderView];
    
    
    
    dictForProfilePictures=[[NSMutableDictionary alloc]init];
    
}




//-(UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}


-(void)TimerCheck
{
//    if ( [[loConnectPHP shareInstance].plistDict[@"firstTimeUse"] isEqualToString:@"YES"] )
//        [self.view bringSubviewToFront:self.loSignUpView];
    
    
    if ([ (NSString*)[loConnectPHP shareInstance].userDictionary[@"group_id"] isEqualToString:@"0"]) {
        // 提示邀請或被邀請
    }else{
       // [self reciveMessage];
    }
    
    
    
    NSString* sqlCommand=[NSString stringWithFormat:@"select isInvited from users where token_id = '%@' ",[loConnectPHP shareInstance].plistDict[@"token_id"]];

    [[loConnectPHP shareInstance]loSQLCommandWithStringReturn:sqlCommand withKey:@"isInvited" Completion:^(NSString *thekey) {
        
        [loConnectPHP shareInstance].plistDict[@"isInvited"]=thekey;
        [[loConnectPHP shareInstance] writePlist];
        
        if ([thekey isEqualToString:@"0"]) {
            return;
        }else{
            
        };
        
    }];
    

    
    
    
    //SELECT max(id) FROM `2`
    NSString* groupID =[loConnectPHP shareInstance].plistDict[@"group_id"];
    
    [[loConnectPHP shareInstance]loSQLCommandWithStringReturn:[NSString stringWithFormat:@"SELECT max(id) FROM `%@`",groupID]//遠端  history maxID
                                                      withKey:@"max(id)"
                                                   Completion:^(NSString *thekey) {
                                                       
                                                       NSString* historyID=[NSString stringWithFormat:@"%d",[[myDB sharedInstance]maxChatHistoryID]];  //近端 history max id
                                                       
                                                      // NSLog(@"thekey :%@ historyID:%@",thekey,historyID);
                                                       
                                                       
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





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadLoTableViewChat" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"setAnnos" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"radarHeading" object:nil];

}



-(void)reCheckData
{
    
}


#pragma mark - IBAction

-(void)changeImageOfLOViewController
{
    
    if (_loImageViewBossWarning.image == [UIImage imageNamed: @"Boss_btn.png"]) {
        
        [_loImageViewBossWarning setImage:[UIImage imageNamed:@"Boss_btnW.png"]];
        
        if (blink == nil) {
            blink=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(blink) userInfo:nil repeats:YES];
        }
        
    }else{
        [_loImageViewBossWarning setImage:[UIImage imageNamed:@"Boss_btn.png"]];
        
        
        [_loViewBlinkWhenWarned setAlpha:0];
        [blink timeInterval];
    }
}
-(void)blink
{
    if (radar.isBossWarning==YES && [radar.whoWarned.profileID isEqualToString:[loConnectPHP shareInstance].plistDict[@"fb_id"]]) {

        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
            
            if (_loViewBlinkWhenWarned.alpha==0) {
                [_loViewBlinkWhenWarned setAlpha:1];
            }else{
                [_loViewBlinkWhenWarned setAlpha:0];
            }
        } completion:^(BOOL finished) {
            
        }];
    }
    
    
}

- (IBAction)loBtnBossWarning:(UIButton *)sender {
    
    if (_loImageViewBossWarning.image == [UIImage imageNamed:@"Boss_btn.png"]) {
        
        //流程 上傳警告到mysql    推push出去  關閉self
        [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"UPDATE  `b16_14177414_bossWarning`.`all_groups` SET  `warned_User_name` =  '%@',`warned_fb_id` =  '%@',`warned_token_id` =  '%@' WHERE  `all_groups`.`group_id` ='%@'",
                                                   @"",
                                                   [loConnectPHP shareInstance].plistDict[@"fb_id"],
                                                   @"",
                                                   [loConnectPHP shareInstance].plistDict[@"group_id"]     ]
                                        afterSYNC:-1
                                       Completion:^{
                                           NSLog(@"updated");
                                           
                                       }];
        
        NSString* groupID= [loConnectPHP shareInstance].plistDict[@"group_id"];
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"BOSS WARNING!   ", @"alert",
                              @"dive.wav", @"sound",
                              nil];
        
        PFPush *push=[[PFPush alloc]init];
        [push setChannel:[NSString stringWithFormat:@"a%@",groupID] ];
        [push setData:data];
        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

            
        }];
        
      //  [_loImageViewBossWarning setImage:[UIImage imageNamed:@"Boss_btnW.png"]];
        
        return;
        
        
    }else{
        
      //  NSLog(@"touched");
        
        if (radar==nil) {
            radar=[[loRadarView alloc]init];
        }
        
        [self.view addSubview:radar];
        
        if (radar.frame.origin.y==-568) {
            [radar show];
        }else{
            [radar hide];
        }
        
     //   NSLog(@"%@",radar);
    }
    
    
    

}

- (IBAction)loBtnMisc:(UIButton *)sender {
    
    
    if (radar.isBossWarning) {
        
        NSString* groupID= [loConnectPHP shareInstance].plistDict[@"group_id"];
        NSString* message=[NSString stringWithFormat:@"Safe!!!  (´▽｀)   "];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%@",message], @"alert",
                              nil];
        
        
        [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"UPDATE  `b16_14177414_bossWarning`.`all_groups` SET  `warned_fb_id` =  '' WHERE  `all_groups`.`group_id` ='%@'",
                                                   [loConnectPHP shareInstance].plistDict[@"group_id"]]
                                        afterSYNC:-1
                                       Completion:^{
                                           
                                           PFPush *push=[[PFPush alloc]init];
                                           [push setChannel:[NSString stringWithFormat:@"a%@",groupID] ];
                                           [push setData:data];
                                           [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                               
                                               if (succeeded) {
                                                   radar.isBossWarning=NO;
                                                   [radar.loLabelWhoWarned setText:@"Safe!!!  (´▽｀)"];
                                                   [radar.loLabelWhoWarned setTextColor:[UIColor colorWithRed:180/256 green:100/256 blue:256/256 alpha:1]];
                                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"changeImageOfLOViewController" object:nil];
                                                   
                                                   [UIView animateWithDuration:1 animations:^{
                                                       radar.warningBar.frame=CGRectMake(0, -160, 320, 292);
                                                       
                                                       _loImageViewBossWarning.image=[UIImage imageNamed:@"Boss_btn.png"];
                                                   }];
                                               }
                                           }];
                                           
                                           
                                           
                                           
                                       }];

        return;
    }
    
    
    
    [self.loFakePopOver setAlpha:1];
    [self.loSubViewMisc setAlpha:1];
    self.loSubViewMisc.frame=CGRectMake( 15,
                                        self.view.bounds.size.height-231,
                                        268,
                                        120);
}

- (IBAction)loBtnChat:(UIButton *)sender {
    

    
    if ([self.loTextViewChat isHidden]) {
        [self.loTextViewChat becomeFirstResponder];
    } else{
        [self sendMessage];
        [self.loTextViewChat setText:nil];
        [self.loTextViewChat resignFirstResponder];
        //[self reloadLoTableViewChat];

    }
    
    
}

#pragma mark - method for IBAction



-(void)sendMessage 
{
    if ([self isConnectionAvailable]) {
        
    }else{
        UIAlertView * alertview= [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"Connection is not available!"
                                                          delegate:self
                                                 cancelButtonTitle:@"ok"
                                                 otherButtonTitles:nil] ;
        [alertview show];
        return;
    }
    
    
    
    if ([_loTextViewChat.text isEqualToString:@""]) {
        return;
    }else if ( [[loConnectPHP shareInstance].plistDict[@"group_id"] isEqualToString:@"0"] ){
        UIAlertView * alertview= [[UIAlertView alloc]initWithTitle:nil
                                                           message:@"you have no group! go create one and invite friends!"
                                                          delegate:self
                                                 cancelButtonTitle:@"ok"
                                                 otherButtonTitles:nil] ;
        [alertview show];
        
        return;
    }
    
    
    
    int sqliteMaxID=[[myDB sharedInstance]maxChatHistoryID];
    sqliteMaxID++;
    tokenID=[loConnectPHP shareInstance].plistDict[@"token_id"];
    
    /*
     INSERT INTO  `b16_14177414_bossWarning`.`2` (`ID` ,`chat_history` ,`time` ,`from_token_id` ,`from_fb_id` ,`user_nickname`)VALUES ('2','ㄕㄕㄕ','','2da2e6e697e7f3b097b8e622d7c91a9a0be8d00cc017e4a05dc66b64dcfa2006',  '1754599854',  'Lova Shih')
     );
    */
    
    
    //丟遠端
    //因為等遠端回應的時間已經nil 須先轉存
    NSString* chatString=[NSString stringWithFormat:@"%@",_loTextViewChat.text];
    
    
    NSLog(@"%d,%@,%@,%@,%@", sqliteMaxID , _loTextViewChat.text , tokenID , FB_ID, [loConnectPHP shareInstance].plistDict[@"user_nickname"]);
    
    [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"INSERT INTO `b16_14177414_bossWarning`.`%@` (`ID` ,`chat_history` ,`time` ,`from_token_id` ,`from_fb_id` ,`user_nickname`)VALUES ('%d','%@','','%@',  '%@',  '%@')",
                                               [loConnectPHP shareInstance].plistDict[@"group_id"] ,
                                               sqliteMaxID,
                                               self.loTextViewChat.text,
                                               tokenID,
                                               FB_ID,
                                               [loConnectPHP shareInstance].plistDict[@"user_nickname"]]
                                    afterSYNC:-1
                                   Completion:^{
                                       
                                       //應該要 遠端丟得上去再存local
                                       
                                       
                                       [[myDB sharedInstance]insertID:[NSString stringWithFormat:@"%d",sqliteMaxID]
                                                         chat_history:chatString
                                                                 time:@""
                                                        from_token_id:tokenID
                                                           from_fb_id:FB_ID
                                                        user_nickname:[loConnectPHP shareInstance].plistDict[@"user_nickname"]  ];
                                       
                                       [self reloadLoTableViewChat];

                                   }];

    //發push
#pragma mark - set push
    NSString* groupID= [loConnectPHP shareInstance].plistDict[@"group_id"];
    
   // NSString* messageSound=[[loConnectPHP shareInstance].plistDict[@"sound"] isEqualToString:@"Yes"]  ?  @"DONGW008.wav" : @""    ;
    
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSString stringWithFormat:@"%@",chatString], @"alert",
                          @"MYmessage2.wav", @"sound",
                          nil];
    
    PFPush *push=[[PFPush alloc]init];
    [push setChannel:[NSString stringWithFormat:@"a%@",groupID] ];
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
 
    }];

}

-(void)reciveMessage
{
    
}
#pragma mark - method for keyboard act
//鍵盤將消失
- (void)loKBWillDisappear:(NSNotification *)notif{
    
    if ( ! self.view.window)
        return;
    
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                            self.loTableViewChat.frame=CGRectMake(0, 20, 320, self.view.bounds.size.height-20-105);
                          
                            
                            self.loToolBarUIView.center = CGPointMake(self.loToolBarUIView.center.x,
                                                                      self.view.bounds.size.height - self.loToolBarUIView.bounds.size.height / 2);
                            
                            self.loViewBossWarning.frame= CGRectMake(self.loToolBarUIView.frame.size.width/2-self.loViewBossWarning.frame.size.width/2,
                                                              self.loToolBarUIView.frame.size.height/2-self.loViewBossWarning.frame.size.height/2,
                                                              self.loViewBossWarning.frame.size.width,
                                                              self.loViewBossWarning.frame.size.height);
                            
                            
                        } completion:^(BOOL finish){
                            [self loTableViewScrollToBottom];
                            [self.loTextViewChat setHidden:YES];
                            [self.loBtnChat setHidden:NO];
                            [self.loBtnChat setTitle:@"" forState:UIControlStateNormal];
                            [self.loViewMisc setHidden:NO];
                            [self.loViewChat setHidden:NO];
                            
                            
                            
                            [self reloadLoTableViewChat];
                            
                        }];
    
}

//鍵盤出現
-(void)loKBWillAppear:(NSNotification *)notif{

    
    if ( ! self.view.window)
        return;
    
    
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                        
                         self.loTableViewChat.frame=CGRectMake(0, 20, 320, self.view.bounds.size.height-105-20-keyboardSize.height);
                         
                         self.loToolBarUIView.center = CGPointMake(self.loToolBarUIView.center.x,
                                                                   self.view.bounds.size.height -  keyboardSize.height - self.loToolBarUIView.bounds.size.height / 2);
                         
                         self.loViewBossWarning.frame= CGRectMake(20,
                                                           self.loToolBarUIView.frame.size.height/2-self.loViewBossWarning.frame.size.height/2,
                                                           self.loViewBossWarning.frame.size.width,
                                                           self.loViewBossWarning.frame.size.height);
                         [self.loViewMisc setHidden:YES];
                         [self.loSubViewMisc setAlpha:0];
                         
                         
                     } completion:^(BOOL finish){
                         
                         [self loTableViewScrollToBottom];
                         
                         self.loTextViewChat.hidden=NO;
                         [self.loViewChat setHidden:YES];
                         [self.loBtnChat setTitle:@"Send" forState:UIControlStateNormal];
                     }];

}


//卷到最下
-(void)loTableViewScrollToBottom
{
    NSIndexPath * lastIndexPath=[self lastIndexPath];
    if ([[[myDB sharedInstance]queryCust] count] >2 ) {
        [self.loTableViewChat scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
//給樓上用的
-(NSIndexPath*) lastIndexPath
{
    NSInteger lastSectionIndex=MAX(0,[self.loTableViewChat numberOfSections]-1);
    NSInteger lastRowIndex=MAX(0,[self.loTableViewChat numberOfRowsInSection:lastSectionIndex]-1);
    return [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
}


//點到cell就收鍵盤
-(void)didTapOnTableView:(UIGestureRecognizer*)recognizer
{
    CGPoint tapLocation=[recognizer locationInView:self.loTableViewChat];
    NSIndexPath *indexPath=[self.loTableViewChat indexPathForRowAtPoint:tapLocation];
    
    if(indexPath)
       [self.loTextViewChat resignFirstResponder];
    
}

//點到墊底的view收 misc
-(void)didTapOnFakePopover:(UITapGestureRecognizer*)recongnizer
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            [self.loSubViewMisc setAlpha:0];
                            [self.loFakePopOver setAlpha:0];
                        } completion:^(BOOL finish){
                            
                        }];
}
-(void)didTapOnSignUpView:(UITapGestureRecognizer*)recongnizer
{
    [self.loTextFieldUserNicknameSignUp resignFirstResponder];
}
#pragma mark - Table view data source



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tempDict count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSAttributedString *astr = [[NSAttributedString alloc]initWithString:tempDict[indexPath.row][@"chat_history"]
                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    CGRect rec = [astr boundingRectWithSize:CGSizeMake(184.0f, MAXFLOAT)
                                    options:NSStringDrawingUsesLineFragmentOrigin
                                    context:nil];
    CGSize size = rec.size;
    
    

    return size.height + 80;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     //https://graph.facebook.com/user_id/picture?redirect=true    to get image
    
    
    NSString* cellID=[NSString stringWithFormat:@"%@", (indexPath.row%2)==0 ? @"Cell" : @"Cell2"  ];
    
    loChatTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
//    self.loProfilePictureView.profileID = user.id;

    
    if ([cellID isEqual:@"Cell"]) {
        [cell.loCell_UserName setText:tempDict[indexPath.row][@"user_nickname"]];
        cell.loCell_HeadPhotoView.layer.cornerRadius=cell.loCell_HeadPhotoView.frame.size.height/2;
        cell.loCell_HeadPhoto.layer.cornerRadius=cell.loCell_HeadPhoto.frame.size.height/2;
        cell.loCell_ChatTextView.text=tempDict[indexPath.row][@"chat_history"];
        
        cell.loCell_userFBHeadPhoto.profileID=nil;
        cell.loCell_userFBHeadPhoto.profileID=tempDict[indexPath.row][@"from_fb_id"];
        cell.loCell_userFBHeadPhoto.layer.cornerRadius = cell.loCell_userFBHeadPhoto.frame.size.height/2;
        
        cell.loCell_ChatTextView.backgroundColor = [[loConnectPHP shareInstance].plistDict[@"bubble"] isEqualToString:@"Yes"]  ?  [UIColor whiteColor] :[UIColor clearColor];
        cell.loCell_ChatTextView.textColor = [[loConnectPHP shareInstance].plistDict[@"bubble"] isEqualToString:@"Yes"]  ?  [UIColor blackColor] :[UIColor blackColor];

    } else if([cellID isEqual:@"Cell2"] ){
        [cell.loCell_2_UserName setText:tempDict[indexPath.row][@"user_nickname"]];
        cell.loCell_2_HeadPhotoView.layer.cornerRadius=cell.loCell_2_HeadPhotoView.frame.size.height/2;
        cell.loCell_2_HeadPhoto.layer.cornerRadius=cell.loCell_2_HeadPhoto.frame.size.height/2;
        cell.loCell_2_ChatTextView.text=tempDict[indexPath.row][@"chat_history"];
        
        cell.loCell_2_userFBHeadPhoto.profileID=nil;
        cell.loCell_2_userFBHeadPhoto.profileID=tempDict[indexPath.row][@"from_fb_id"];
        cell.loCell_2_userFBHeadPhoto.layer.cornerRadius = cell.loCell_2_userFBHeadPhoto.frame.size.height/2;
        
        cell.loCell_2_ChatTextView.backgroundColor = [[loConnectPHP shareInstance].plistDict[@"bubble"] isEqualToString:@"Yes"]  ?  [UIColor colorWithRed:0.2 green:0.66 blue:0.64 alpha:0.9f] :[UIColor clearColor];
        cell.loCell_2_ChatTextView.textColor = [[loConnectPHP shareInstance].plistDict[@"bubble"] isEqualToString:@"Yes"]  ?  [UIColor whiteColor] :[UIColor blackColor];
        cell.contentView.backgroundColor=[[loConnectPHP shareInstance].plistDict[@"bubble"] isEqualToString:@"Yes"]  ?  [UIColor clearColor] :[UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:1] ;

        cell.bubbleView.backgroundColor=cell.loCell_2_ChatTextView.backgroundColor;
    }
    
//    NSLog(@"%@",tempDict[indexPath.row][@"from_fb_id"]);
    

    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect frame = cell.loCell_ChatTextView.frame;
        cell.loCell_ChatTextView.frame =CGRectMake(frame.origin.x,
                                                   frame.origin.y,
                                                   frame.size.width,
                                                   [self contentSizeOfTextView:cell.loCell_ChatTextView].height);
        
        cell.loCell_2_ChatTextView.frame=cell.loCell_ChatTextView.frame;
        
        cell.bubbleView.frame=CGRectMake(cell.bubbleView.frame.origin.x,
                                         cell.bubbleView.frame.origin.y,
                                         cell.bubbleView.frame.size.width,
                                         cell.loCell_2_ChatTextView.frame.size.height);
        
        
        cell.bubbleView1.frame=CGRectMake(cell.bubbleView.frame.origin.x,
                                         cell.bubbleView.frame.origin.y,
                                         cell.bubbleView.frame.size.width,
                                         cell.loCell_2_ChatTextView.frame.size.height);
    });
    
    return cell;
}



-(void)headerTouched
{
    int chatHistoryCount = [[myDB sharedInstance]maxChatHistoryID];
    
    int gap=chatHistoryCount - numberOfShowMessages;
    
    if (gap<0){
        [btnForHeaderView setTitle:@"All Here" forState:UIControlStateNormal];
        return;
    }
    
    switch (gap) {
        case 1 ... 19:
            numberOfShowMessages += gap;
            break;
        case 20 ... 1000000000:
            numberOfShowMessages += 20;
            break;
        default:
            break;
    }
    
    [self reloadLoTableViewChat];    //[self loTableViewScrollToBottom];
}


- (CGSize)contentSizeOfTextView:(UITextView *)textView
{
    CGSize textViewSize = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, FLT_MAX)];
    return textViewSize;
}

-(void)reloadLoTableViewChat
{
    if (tempDict==nil)    tempDict =[[NSMutableArray alloc]init];

    tempDict = [[myDB sharedInstance]queryCust];
    
  //  NSLog(@"reloadLoTableViewChat tempDict = %@",tempDict);
    
    
    
    //只留最後 numberOfShowMessages筆 用於顯示
    
    NSMutableArray* array=[[NSMutableArray alloc]init];
   
    if ([tempDict count] > numberOfShowMessages) {
        for (int i = ([tempDict count]-numberOfShowMessages) ; i<= [tempDict count]; i++) {
            //[array addObject:tempDict[i-1]];
            //NSLog(@"i=%d",i);
        }
    }
#warning chat history 部分顯示
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_loTableViewChat reloadData];
        [self loTableViewScrollToBottom];
    });
    
    
    
}
#pragma mark - come back

-(IBAction)mackToMain:(UIStoryboardSegue*)back
{
    [self reloadInputViews];
    [self.loFakePopOver setAlpha:0];
    [self.loSubViewMisc setAlpha:0];

    [_loTableViewChat reloadData];
    [self loTableViewScrollToBottom];
}


#pragma mark - sign view IBAction
- (IBAction)loBtnSignUP:(UIButton *)sender {
    

    
    
    if (self.loTextFieldUserNicknameSignUp.text !=nil) {
        
        [loConnectPHP shareInstance].plistDict[@"user_nickname"] = self.loTextFieldUserNicknameSignUp.text;
        [[loConnectPHP shareInstance] writePlist];
        
        [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"update users set user_nickname='%@' , FB_ID='%@' where token_id='%@'",
                                                   [loConnectPHP shareInstance].plistDict[@"user_nickname"] ,
                                                   FB_ID,
                                                   [loConnectPHP shareInstance].plistDict[@"token_id"]     ]
                                        afterSYNC:-1
                                       Completion:^{}];
    }
    
    [loConnectPHP shareInstance].plistDict[@"firstTimeUse"] = @"NO";
    
    [[loConnectPHP shareInstance] writePlist];
    
    [self.loTextFieldUserNicknameSignUp resignFirstResponder];

    [self.view sendSubviewToBack:self.loSignUpView];
    
    [self reloadLoTableViewChat];
    
    
    NSLog(@"fb %@",FB_ID);
}


- (IBAction)loBtnSignViewChangeUserPic:(UIButton *)sender {
    
}



- (IBAction)loBtnGoOption:(UIButton *)sender {
    
//    self.loSubViewMisc.frame=CGRectMake( 15,
//                                        self.view.bounds.size.height-231,
//                                        268,
//                                        120);
    [self didTapOnFakePopover:nil];
    
}

- (IBAction)loBtnWarningOthers:(UIButton *)sender {
    
    loWarningOthersView* theView = [[loWarningOthersView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
    
    [self.view addSubview:theView];
    
        [self.loSubViewMisc setAlpha:0];
        [self.loFakePopOver setAlpha:0];

}

#pragma mark - for fb

-(void)FBloginview
{
    if (_loLoginView==nil) {
        _loLoginView= [[FBLoginView alloc]initWithReadPermissions:@[@"basic_info"]];
    }
    
    _loLoginView.delegate=self;
    
    _loLoginView.frame=CGRectMake(40, 180, 120, 50);
    
    loLoginViewCoverImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0 , 120, 50)];
    [loLoginViewCoverImage setImage:[UIImage imageNamed:@"facebook_login.png"]];
    [_loLoginView addSubview:loLoginViewCoverImage];
    _loLoginView.layer.cornerRadius=5;

}


#pragma mark - fb delegate

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    if (FB_ID ==nil)
        FB_ID=[[NSString alloc]init];
    
    FB_ID= user.id;
    self.loProfilePictureView.profileID=user.id;
    self.loViewMiscFBProfilePictureView.profileID=FB_ID;
    //第一次用才使用fb nickname 之後都custom;
    if ([[loConnectPHP shareInstance].plistDict[@"firstTimeUse"] isEqualToString:@"YES"] ) {
        self.loTextFieldUserNicknameSignUp.text = user.name;
    }else{
        [self.loTextFieldUserNicknameSignUp setText:[loConnectPHP shareInstance].plistDict[@"user_nickname"]];
    }
    
    
    [loConnectPHP shareInstance].plistDict[@"fb_id"]=FB_ID;
    [[loConnectPHP shareInstance] writePlist];
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView
{
    [loLoginViewCoverImage setImage:[UIImage imageNamed:@"facebook_logout.png"]];
    
    [self.loBtnSignUp setEnabled:YES];
    
    FBRequest* friendRequest=[FBRequest requestForMyFriends];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection,
                                               NSDictionary* result,
                                               NSError *error) {
        _fbFriends=result[@"data"];
        //fb
        
//        {
//            "first_name" = Joly;
//            id = 539372716;
//            "last_name" = Huang;
//            name = "Joly Huang";
//            username = "joly.huang.7";
//        }
//        NSLog(@"result = %@",result[@"data"][1][@"first_name"]);
//        NSLog(@"result = %@",result[@"data"][1]);

      //  NSLog(@"all of %lu friends",(unsigned long)[result[@"data"] count]);
       // NSLog(@"%@",_fbFriends);
    }];
    
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView
{
    self.loProfilePictureView.profileID=nil;
    self.loTextFieldUserNicknameSignUp.text = nil;
    [loLoginViewCoverImage setImage:[UIImage imageNamed:@"facebook_login.png"]];
    [self.loBtnSignUp setEnabled:NO];

}



-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    //NSLog(@"error :%@",error);
    
    

}

#pragma mark - set AnnoView
-(void)setAnnos
{
    [radar setAnnos:[loConnectPHP shareInstance].UsersLocation];
}



#define degreesToRadians(x) (M_PI * (x) / 180.0)

//-(void)radarHeading:(CLHeading *)newHeading
//{
//  //  NSLog(@"%@",newHeading);
//
#warning bug here
// radar.viewForAnnotationView.transform = CGAffineTransformMakeRotation((newHeading.trueHeading*-1)/180 * M_PI  );
//    
//}


- (BOOL) isConnectionAvailable
{
	SCNetworkReachabilityFlags flags;
    BOOL receivedFlags;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"dipinkrishna.com" UTF8String]);
    receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!receivedFlags || (flags == 0) )
    {
        return FALSE;
    } else {
		return TRUE;
	}
}



-(void)showAlert:(NSString*)message
{
//    NSLog(@"message %@",message);
//    UIAlertView* alert=[[UIAlertView alloc]initWithTitle:nil
//                                                 message:message
//                                                delegate:self
//                                       cancelButtonTitle:nil
//                                       otherButtonTitles:@"OK",nil];
//    [alert show];
}

-(void)shut
{
    
    [_loViewBlinkWhenWarned setAlpha:0];
}
@end
