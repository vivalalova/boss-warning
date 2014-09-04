//
//  loInvitedView.m
//  xp802Push
//
//  Created by Lova on 2014/3/16.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import "loInvitedView.h"
#import "loConnectPHP.h"
#import <FacebookSDK/FacebookSDK.h>
@interface loInvitedView()<UIAlertViewDelegate>


@end

@implementation loInvitedView


-(id)init
{
    self= [super init];
    if (self) {
        
        self.frame=CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        } completion:^(BOOL finished) {
            
        }];
        
        [self inviteShow];
        
    }
    return self;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(BOOL)inviteShow
{
    UIView* inviteView=[[UIView alloc]initWithFrame:CGRectMake(40, 80, 239, 123)];
    inviteView.layer.cornerRadius=10;
    
    FBProfilePictureView* whoInviteUser=[[FBProfilePictureView alloc]initWithFrame:CGRectMake(20, 20, 44, 44 )];
    whoInviteUser.profileID=[loConnectPHP shareInstance].plistDict[@"isInvited"];
    whoInviteUser.layer.cornerRadius=whoInviteUser.frame.size.width/2;
    [inviteView addSubview:whoInviteUser];
    
    UILabel* inviteMessage=[[UILabel alloc]initWithFrame:CGRectMake(72, 31, 139, 21)];
    inviteMessage.text=[NSString stringWithFormat:@"i invited you to join my group"];
    inviteMessage.lineBreakMode = NSLineBreakByWordWrapping;
    inviteMessage.numberOfLines=0;
    [inviteView addSubview:inviteMessage];
    
    UIButton* btnCancel=[[UIButton alloc]initWithFrame:CGRectMake(0, 79, 100, 44)];
    [btnCancel setTitle:@"Reject" forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(btnCancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:inviteView];
    return YES;
}

-(BOOL)btnCancel
{
    [[loConnectPHP shareInstance]loSQLCommandWithStringReturn:@"" withKey:@"" Completion:^(NSString *thekey) {
        
    }];
    
    [self removeFromSuperview];
    return YES;
}


@end
