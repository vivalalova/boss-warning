//
//  loViewController.h
//  xp802Push
//
//  Created by Lova on 2014/1/6.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface loViewController : UIViewController<FBLoginViewDelegate>

@property (strong,nonatomic)  IBOutlet UILabel * loLabel;

@property (strong,nonatomic)  UITableView * loTableViewForChat;
@property (strong, nonatomic) IBOutlet UITableView *loTableViewChat;

@property (strong, nonatomic) IBOutlet UIView *loViewBlinkWhenWarned;
@property (strong, nonatomic) IBOutlet UIView *loToolBarUIView;
@property (strong, nonatomic) IBOutlet UIView *loViewBossWarning;
@property (strong, nonatomic) IBOutlet UIView *loViewChat;
@property (strong, nonatomic) IBOutlet UIButton *loBtnChat;
@property (strong, nonatomic) IBOutlet UIView *loViewMisc;
@property (strong, nonatomic) IBOutlet UIView *loViewMiscBottom;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *loViewMiscFBProfilePictureView;
@property (strong, nonatomic) IBOutlet UITextView *loTextViewChat;
@property (strong, nonatomic) IBOutlet UIImageView *loImageViewBossWarning;


#pragma mark - misc
@property (strong, nonatomic) IBOutlet UIView *loSubViewMisc;
@property (strong, nonatomic) IBOutlet UIView *loFakePopOver;
- (IBAction)loBtnGoOption:(UIButton *)sender;
- (IBAction)loBtnWarningOthers:(UIButton *)sender;



#pragma mark - sign up
@property (strong,nonatomic)           NSArray* fbFriends;
@property (strong, nonatomic) IBOutlet UIButton *loBtnSignUp;
@property (strong,nonatomic)           FBLoginView *loLoginView;
@property (strong, nonatomic) IBOutlet UIView *loSignUpView;
@property (strong, nonatomic) IBOutlet UIImageView *loImageViewSignUpUserPic;
@property (strong, nonatomic) IBOutlet UITextField *loTextFieldUserNicknameSignUp;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *loProfilePictureView;
@property (strong, nonatomic) IBOutlet UIView *loSignUpSubView;
- (IBAction)loBtnSignUP:(UIButton *)sender;
- (IBAction)loBtnSignViewChangeUserPic:(UIButton *)sender;



#pragma mark- IBAction
- (IBAction)loBtnBossWarning:(UIButton *)sender;
- (IBAction)loBtnMisc:(UIButton *)sender;
- (IBAction)loBtnChat:(UIButton *)sender;



-(IBAction)mackToMain:(UIStoryboardSegue*)back;

#pragma mark - boss warning  raider

@end
