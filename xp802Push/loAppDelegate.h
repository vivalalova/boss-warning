//
//  loAppDelegate.h
//  xp802Push
//
//  Created by Lova on 2014/1/6.
//  Copyright (c) 2014年 Lova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>


@interface loAppDelegate : UIResponder <UIApplicationDelegate>
{
    SystemSoundID soundFileObject;

}
@property (strong,nonatomic)    NSString *tokenString;
@property (strong, nonatomic)   UIWindow *window;


@end
