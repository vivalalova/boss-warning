//
//  loRadarView.h
//  xp802Push
//
//  Created by Lova on 2014/2/26.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface loRadarView : UIView<UIActionSheetDelegate>

@property BOOL isBossWarning;
@property (strong,nonatomic)    UILabel* loLabelWhoWarned;
@property (strong,nonatomic)    UIView* warningBar;
@property (strong,nonatomic)    UIView* viewForAnnotationView;
@property (strong,nonatomic)    FBProfilePictureView*   whoWarned;


- (id)init;
-(void)show;
-(void)hide;
-(void)gotBossWarning;
-(void)setAnnos:(NSMutableArray*)usersLocation;

@end
