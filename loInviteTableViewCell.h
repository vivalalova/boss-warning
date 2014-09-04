//
//  loInviteTableViewCell.h
//  xp802Push
//
//  Created by Lova on 2014/3/12.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface loInviteTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet FBProfilePictureView *loFriendPhoto;
@property (strong, nonatomic) IBOutlet UILabel *loFriendNickName;
@property (strong, nonatomic) IBOutlet UIImageView *loImageViewIfInvited;
@end
