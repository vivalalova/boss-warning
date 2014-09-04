//
//  loSetupTableViewController.h
//  xp802Push
//
//  Created by Lova on 2014/2/4.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface loSetupTableViewController : UITableViewController<FBWebDialogsDelegate , FBLoginViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UITextField *loUserNickname;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *loSetupFBprofilePhotoView;

@property (strong, nonatomic) IBOutlet UITableViewCell *loFBcell;

@property (strong, nonatomic) IBOutlet UILabel *loLabelGroupState;
@property (strong, nonatomic) IBOutlet UISwitch *loSwitcherVibrate;
@property (strong, nonatomic) IBOutlet UISwitch *loSwitcherSound;
@property (strong, nonatomic) IBOutlet UISwitch *loSwitcherBubble;
@property (strong, nonatomic) IBOutlet UIButton *loBtnJoin;
- (IBAction)loBtnJoin:(UIButton *)sender;
- (IBAction)loBtnCreateGroup:(UIButton *)sender;
- (IBAction)loBtnInviteFriends:(UIButton *)sender;


- (IBAction)loBtnSetupDone:(UIBarButtonItem *)sender;
- (IBAction)loSwitcherChanged:(UISwitch *)sender;
@end
