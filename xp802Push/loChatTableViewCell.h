//
//  loChatTableViewCell.h
//  xp802Push
//
//  Created by Lova on 2014/1/23.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface loChatTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *loCell_HeadPhotoView;
@property (strong, nonatomic) IBOutlet UIImageView *loCell_HeadPhoto;
@property (strong, nonatomic) IBOutlet UILabel *loCell_UserName;
@property (strong, nonatomic) IBOutlet UITextView *loCell_ChatTextView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *loCell_userFBHeadPhoto;
@property (strong, nonatomic) IBOutlet UIView *bubbleView1;
//===========cell2=================
@property (strong, nonatomic) IBOutlet UIView *loCell_2_HeadPhotoView;
@property (strong, nonatomic) IBOutlet UIImageView *loCell_2_HeadPhoto;
@property (strong, nonatomic) IBOutlet UILabel *loCell_2_UserName;
@property (strong, nonatomic) IBOutlet UITextView *loCell_2_ChatTextView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *loCell_2_userFBHeadPhoto;
@property (strong, nonatomic) IBOutlet UIView *bubbleView;


//=====Cell3=====

@property (strong, nonatomic) IBOutlet FBProfilePictureView *warningYou;
@property (strong, nonatomic) IBOutlet UILabel *warningWhoNamed;


@end
