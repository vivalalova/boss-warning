//
//  loWarningOthersView.m
//  xp802Push
//
//  Created by Lova on 2014/2/24.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loWarningOthersView.h"
#import <FacebookSDK/FacebookSDK.h>
#import "loConnectPHP.h"
#import "loLocation.h"
#import <Parse/Parse.h>


UIView* bgView;
FBProfilePictureView* selfPhoto;
NSMutableArray* arrayForFriendSubView;

NSString* fbID_toWarn;


@implementation loWarningOthersView



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImageView* back=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 568)];
            back.image = [UIImage imageNamed:@"Alert_background.png"];
            [self addSubview:back];
            [back sendSubviewToBack:self];
            
        });

        UITapGestureRecognizer* tapView= [[ UITapGestureRecognizer alloc]initWithTarget:self
                                                                                 action:@selector(remove)];
        [self addGestureRecognizer:tapView];
        
        
        

        [self initSelfPhoto];
        
        [self addSubview:bgView];

        [self selfPhotoMove];
        
        
        
        [[loLocation sharedInstance].locationManager startUpdatingLocation];  //開gps與記錄位置

    }
    return self;
}

-(void)initSelfPhoto
{
    bgView= [[UIView alloc]initWithFrame:CGRectMake(115,
                                                    self.bounds.size.height-215,
                                                    68,
                                                    68)];
    
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius=bgView.frame.size.height/2;
    
//    selfPhoto= [[FBProfilePictureView alloc]initWithFrame:CGRectMake(4, 4, 60, 60)];
//    selfPhoto.layer.cornerRadius=selfPhoto.frame.size.height/2;
//    selfPhoto.profileID=[loConnectPHP shareInstance].plistDict[@"fb_id"];
    
    
    
    
    UIImageView* warn=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Alert_btn.png"]];
    warn.frame=CGRectMake(4, 4, 60, 60);
    
    [bgView addSubview:warn];
    
    

    
    

    
    
    UITapGestureRecognizer* tapSelf=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(warnYourMother)];
    [bgView addGestureRecognizer:tapSelf];
    

}

-(void)selfPhotoMove
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut  //UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         bgView.frame=CGRectMake(28, 252, bgView.frame.size.width, bgView.frame.size.height);
                         
    } completion:^(BOOL finished) {
        
        [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"SELECT FB_ID FROM `users` where group_id = '%@'",[loConnectPHP shareInstance].plistDict[@"group_id"]]
                                        afterSYNC:loAfterASYNC_DO_getUsersFB
                                       Completion:^{
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               [self friendPops];
                                           });
                                           
                                       }];
    }];
}

-(void)remove
{
    [self removeFromSuperview];

}

#pragma mark - friendPops
-(void)friendPops
{
    arrayForFriendSubView=nil;

    arrayForFriendSubView=[[NSMutableArray alloc]init];
    
//    [[loConnectPHP shareInstance].fbIDArray addObject:@"100003074734964"];
//    [[loConnectPHP shareInstance].fbIDArray addObject:@"626510946"];

    double y=80.0;
    
    for (NSString* fbID in [loConnectPHP shareInstance].fbIDArray) {
        
        double deltaX =sqrt( pow(174,2)  - pow((y-252), 2) );
        double x = 28 +deltaX;
        
        
        CGRect frame=CGRectMake(floor(x),floor(y),68,68);
        
        [arrayForFriendSubView addObject:[self friendsPhoto:frame fbID:fbID]];
    
        y+=75;
    }
    
    for (UIView* view in arrayForFriendSubView) {
        
        [self addSubview:view];
        [self ViewShake:view];
    }

    
}

-(UIView*)friendsPhoto:(CGRect)frame fbID:(NSString*)fbID
{
  //  NSLog(@"fbid=%@",fbID);
    UIView* friendBgView=[[UIView alloc]initWithFrame:frame];
    friendBgView.backgroundColor=[UIColor whiteColor];
    friendBgView.layer.cornerRadius=friendBgView.frame.size.height/2;
    
    
    FBProfilePictureView* friendProfilePictureView=[[FBProfilePictureView alloc]initWithFrame:CGRectMake(4, 4, 60, 60)];
    friendProfilePictureView.layer.cornerRadius = friendProfilePictureView.frame.size.height/2;
    friendProfilePictureView.profileID=fbID;
    friendProfilePictureView.backgroundColor=[UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.1f];
    
    UITapGestureRecognizer* tapView= [[ UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(warningFriend:)];
    [friendProfilePictureView addGestureRecognizer:tapView];

    [friendBgView addSubview:friendProfilePictureView];

    return friendBgView;
}

-(void)ViewShake:(UIView*)view
{
    UIView* subview= [view.subviews lastObject];

    [UIView animateWithDuration:0.2 animations:^{
        view.frame=CGRectMake(view.frame.origin.x-3,
                              view.frame.origin.y-3,
                              view.frame.size.width+6,
                              view.frame.size.height+6);
        subview.frame=CGRectMake(subview.frame.origin.x,
                              subview.frame.origin.y,
                              subview.frame.size.width+6,
                              subview.frame.size.height+6);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        view.frame=CGRectMake(view.frame.origin.x+3,
                              view.frame.origin.y+3,
                              view.frame.size.width-6,
                              view.frame.size.height-6);
        subview.frame=CGRectMake(subview.frame.origin.x,
                                 subview.frame.origin.y,
                                 subview.frame.size.width-6,
                                 subview.frame.size.height-6);
    }];
    

}


#pragma mark - tap on friends
-(void)warningFriend:(UITapGestureRecognizer*)sender
{
    FBProfilePictureView* view=(FBProfilePictureView*)sender.view;
    

    UIView* yellowRing = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 76, 76)];
    yellowRing.layer.cornerRadius=yellowRing.frame.size.height/2;
    
    yellowRing.backgroundColor=[UIColor yellowColor];
    yellowRing.center=[sender.view superview].center;
    
    [self addSubview:yellowRing];
    [self sendSubviewToBack:yellowRing];
    
    [sender.view superview].backgroundColor=[UIColor whiteColor];
    
   // NSLog(@"%@",[view superview]);
    
    [self ViewShake:[view superview]];
    
    fbID_toWarn=view.profileID;

}

-(void)warnYourMother
{
    NSLog(@"wwww%@",fbID_toWarn);
    //流程 上傳警告到mysql    推push出去  關閉self
    [[loConnectPHP shareInstance]loSQLCommand:[NSString stringWithFormat:@"UPDATE  `b16_14177414_bossWarning`.`all_groups` SET  `warned_User_name` =  '%@',`warned_fb_id` =  '%@',`warned_token_id` =  '%@' WHERE  `all_groups`.`group_id` ='%@'",
                                               @"",
                                               fbID_toWarn,
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
        [UIView animateWithDuration:0.5 animations:^{
            [self setAlpha:0];
        } completion:^(BOOL finished) {
            [self remove];
        }];
    }];
    ///////////////
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
